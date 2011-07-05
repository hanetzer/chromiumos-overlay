# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

#
# Original Author: The Chromium OS Authors <chromium-os-dev@chromium.org>
# Purpose: Install FDT files for firmware construction.
#

# @ECLASS-VARIABLE: CROS_FDT_SOURCES
# @DESCRIPTION:
# List of FDT source files to compile (without extension)
# Each file must exist in CROS_FDT_ROOT, with a .dts extension
: ${CROS_FDT_SOURCES:=}

# @ECLASS-VARIABLE: CROS_FDT_ROOT
# @DESCRIPTION:
# Root directory containing all FDT files
: ${CROS_FDT_ROOT:=}

# Check for EAPI 2 or 3
case "${EAPI:-0}" in
	3|2) ;;
	1|0|:) DEPEND="EAPI-UNSUPPORTED" ;;
esac

# Convert a filename into a full path name
get_path_name() {
	local name="${1%.dts}"
	echo "${CROS_FDT_ROOT}/${name}.dts"
}

get_source_files() {
	echo "${CROS_FDT_ROOT}/${CROS_FDT_SOURCES}.dts"
}

get_dtb() {
	local dtb="$1"

	dtb="$(basename ${dtb%.dts}).dtb"
	echo "${dtb}"
}

cros-fdt_src_configure() {
	local file

	[ -d "${CROS_FDT_ROOT}" ] ||
		die "FDT_ROOT directory '${CROS_FDT_ROOT}' does not exist"
	einfo "Using FDT source directory: ${CROS_FDT_ROOT}"
	einfo "Using FDT source files: ${CROS_FDT_SOURCES}"

	for file in $(get_source_files); do
		[ -f "${file}" ] ||
			die "FDT file '${file}' does not exist"
	done
}

cros-fdt_src_compile() {
	for file in $(get_source_files); do
		local dtb=$(get_dtb "${file}")
		einfo "Compiling ${file}"
		dtc -R 4 -p 0x1000 -O dtb -o "${dtb}" "${file}"
	done
}

cros-fdt_src_install() {
	dodir /u-boot/dtb
	insinto /u-boot/dtb

	for file in $(get_source_files); do
		local dtb=$(get_dtb "${file}")
		einfo "Installing ${dtb}"
		doins "${dtb}"
	done
}

EXPORT_FUNCTIONS src_configure src_compile src_install
