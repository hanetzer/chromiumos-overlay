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

RDEPEND="chromeos-base/chromeos-config-bsp:="

# This ebuild creates the Chrome OS master configuration file stored in
# ${UNIBOARD_DTB}. See go/cros-unified-builds-design for more information.

# There is no workon source directory, so use the work directory.
S=${WORKDIR}

# Use the device-tree compiler to create and install a config.dtb file
# containing all the .dtsi files from ${UNIBOARD_DTS_DIR}.
src_compile() {
	local dts="${WORKDIR}/config.dts"
	local dtb="${WORKDIR}/config.dtb"
	local added=0
	local dtsi

	# Create a .dts file with all the includes.
	cat "${FILESDIR}/skeleton.dts" >"${dts}"
	for dtsi in "${SYSROOT}${UNIBOARD_DTS_DIR}"/*.dtsi; do
		if [[ ! -f "${dtsi}" ]]; then
			die "No .dtsi files found in \
${SYSROOT}${UNIBOARD_DTS_DIR}: please check that you have a \
chromeos-config-model virtual ebuild"
		fi
		einfo "Adding ${dtsi}"
		cp "${dtsi}" "${WORKDIR}"
		# Drop the directory path from ${dtsi} in the #include.
		echo "#include \"${dtsi##*/}\"" >> "${dts}"
		: $((added++))
	done
	einfo "${added} files found"

	# Use the preprocessor to handle the #include directives.
	$(tc-getCPP) -P -x assembler-with-cpp "${dts}" -o "${dts}.tmp" \
		|| die "Preprocessor failed"

	# Compile it to produce the requird output file.
	dtc -I dts -O dtb -o "${dtb}" "${dts}.tmp" \
		|| die "Device-tree compilation failed"
}

src_install() {
	# Get the directory name only, and use that as the install directory.
	insinto "${UNIBOARD_DTB_INSTALL_PATH%/*}"
	doins config.dtb
}
