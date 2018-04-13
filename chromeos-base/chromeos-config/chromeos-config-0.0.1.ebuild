# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

# We can drop this if cros-uniboard stops using cros-board.
CROS_BOARDS=( none )

inherit cros-unibuild toolchain-funcs

DESCRIPTION="Chromium OS-specific configuration"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

DEPEND="
	virtual/chromeos-config-bsp:=
"
RDEPEND="${DEPEND}"

# This ebuild creates the Chrome OS master configuration file stored in
# ${UNIBOARD_DTB}. See go/cros-unified-builds-design for more information.

# There is no workon source directory, so use the work directory.
S=${WORKDIR}

# Use the device-tree compiler to create and install a config.dtb file
# containing all the .dtsi files from ${UNIBOARD_DTS_DIR}.
# For YAML files, convert them into JSON for platform runtime access.
src_compile() {
	local dts="${WORKDIR}/config.dts"
	local dtb="${WORKDIR}/config.dtb"
	local added=0
	local dtsi
	local files=( "${SYSROOT}${UNIBOARD_DTS_DIR}/"*.dtsi )
	local schema_info="${WORKDIR}/_dir_targets.dtsi"

	# Create a .dts file with all the includes.
	cp "${FILESDIR}/skeleton.dts" "${dts}"
	cros_config_host write-target-dirs >"${schema_info}" \
		|| die "Failed to write directory targets"
	cros_config_host write-phandle-properties >>"${schema_info}" \
		|| die "Failed to write phandle properties"
	# For YAML cases, we still need to generate a shell DTB file for
	# now since mosys still attempts to link it in.
	if [[ "${files[0]}" =~ .*[a-z_]+\.dtsi$ ]]; then
		for dtsi in "${SYSROOT}${UNIBOARD_DTS_DIR}"/*.dtsi "${schema_info}"; do
			einfo "Adding ${dtsi}"
			[[ "${dtsi}" != "${schema_info}" ]] && cp "${dtsi}" "${WORKDIR}"
			# Drop the directory path from ${dtsi} in the #include.
			echo "#include \"${dtsi##*/}\"" >> "${dts}"
			: $((added++))
		done
		einfo "${added} files found"
	fi

	# Use the preprocessor to handle the #include directives.
	$(tc-getCPP) -P -x assembler-with-cpp "${dts}" -o "${dts}.tmp" \
		|| die "Preprocessor failed"

	# Compile it to produce the requird output file.
	dtc -I dts -O dtb -Wno-unit_address_vs_reg -o "${dtb}" "${dts}.tmp" \
		|| die "Device-tree compilation failed"

	# Validate the config.
	einfo "Validating config:"
	validate_config "${dtb}" || die "Validation failed"
	einfo "- OK"


	# YAML config support.
	local yaml_files=( "${SYSROOT}${UNIBOARD_YAML_DIR}/"*.yaml )
	local yaml="${WORKDIR}/config.yaml"
	local c_file="${WORKDIR}/config.c"
	local json="${WORKDIR}/config.json"
	local gen_yaml="${SYSROOT}${UNIBOARD_YAML_DIR}/config.yaml"
	if [[ "${yaml_files[0]}" =~ .*[a-z_]+\.yaml$ ]]; then
		echo "# Generated YAML config file" > "${yaml}"
		for source_yaml in "${yaml_files[@]}"; do
			if [[ "${source_yaml}" != "${gen_yaml}" ]]; then
				einfo "Adding source YAML file ${source_yaml}"
				cat "${source_yaml}" >> "${yaml}"
			fi
		done
		cros_config_schema -c "${yaml}" -o "${json}" -g "${c_file}" -f "True" \
			|| echo "Warning: Validation failed"
	else
		einfo "Emitting empty c interface config for mosys."
		cp "${FILESDIR}/empty_config.c" "${c_file}"
	fi
}

src_install() {
	# Get the directory name only, and use that as the install directory.
	if [[ -e "${WORKDIR}/config.dtb" ]]; then
		insinto "${UNIBOARD_DTB_INSTALL_PATH%/*}"
		doins config.dtb
	fi

	if [[ -e "${WORKDIR}/config.json" ]]; then
		insinto "${UNIBOARD_JSON_INSTALL_PATH%/*}"
		doins config.json
	fi
	insinto "${UNIBOARD_YAML_DIR}"
	doins config.c
	if [[ -e "${WORKDIR}/config.yaml" ]]; then
		doins config.yaml
	fi
}
