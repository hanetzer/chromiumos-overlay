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

	if [[ "${#files[@]}" -gt 0 ]]; then
		# Create a .dts file with all the includes.
		cat "${FILESDIR}/skeleton.dts" >"${dts}"
		cros_config_host write-target-dirs >"${schema_info}" \
			|| die "Failed to write directory targets"
		cros_config_host write-phandle-properties >>"${schema_info}" \
			|| die "Failed to write phandle properties"
		for dtsi in "${SYSROOT}${UNIBOARD_DTS_DIR}"/*.dtsi "${schema_info}"; do
			einfo "Adding ${dtsi}"
			[[ "${dtsi}" != "${schema_info}" ]] && cp "${dtsi}" "${WORKDIR}"
			# Drop the directory path from ${dtsi} in the #include.
			echo "#include \"${dtsi##*/}\"" >> "${dts}"
			: $((added++))
		done
		einfo "${added} files found"

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
	fi


	# YAML config support.
	local files=( "${SYSROOT}${UNIBOARD_YAML_DIR}/"*.yaml )
	local yaml="${SYSROOT}${UNIBOARD_YAML_CONFIG}"
	local json="${WORKDIR}/config.json"
	if [[ "${files[0]}" =~ .*[a-z_]+\.yaml$ ]]; then
		echo "# YAML generated from: ${files[*]}" > "${yaml}"
		# This needs to be smarter eventually where it makes sure the
		# common YAML file is inserted first before the model-specific
		# YAML files.
		# This hasn't been fully vetted yet, so punting until then.
		cat "${files[@]}" >> "${yaml}"
		cros_config_schema -c "${yaml}" -o "${json}" -f "True" \
			|| echo "Warning: Validation failed"
	fi
}

src_install() {
	# Get the directory name only, and use that as the install directory.
	insinto "${UNIBOARD_DTB_INSTALL_PATH%/*}"
	doins config.dtb

	if [[ -e "${WORKDIR}/config.json" ]]; then
		doins config.json
	fi
}
