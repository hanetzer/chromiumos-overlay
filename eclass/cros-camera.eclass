# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: platform.eclass
# @MAINTAINER:
# Chromium OS Camera Team
# @BUGREPORTS:
# Please report bugs via http://crbug.com/new (with label Build)
# @VCSURL: https://chromium.googlesource.com/chromiumos/overlays/chromiumos-overlay/+/master/eclass/@ECLASS@
# @BLURB: helper eclass for building Chromium package in src/platform/arc-camera
# @DESCRIPTION:
# Packages in src/platform/arc-camera are in active development. We want builds
# to be incremental and fast. This centralized the logic needed for this.

# @ECLASS-VARIABLE: CROS_CAMERA_TESTS
# @DESCRIPTION:
# A list of tests to run when FEATURES=test is set.
: ${CROS_CAMERA_TESTS:=}

PLATFORM_SUBDIR="arc-camera"

inherit platform

cros-camera_src_unpack() {
	local s="${S}"
	platform_src_unpack
	S="${s}/platform/${PLATFORM_SUBDIR}"
}

cros-camera_doheader() {
	local INCLUDE_DIR="/usr/include/cros-camera"
	insinto ${INCLUDE_DIR}

	local header_file
	for header_file in "$@"; do
		doins "${header_file}"
	done
}

cros-camera_dohal() {
	local src=$1
	local dst=$2
	insinto "/usr/$(get_libdir)/camera_hal"
	newins "${src}" "${dst}"
}

cros-camera_dopc() {
	local in_pc_file=$1
	local out_pc_file=${in_pc_file%%.template}
	local INCLUDE_DIR="/usr/include/cros-camera"
	local LIB_DIR="/usr/$(get_libdir)"

	sed -e "s|@INCLUDE_DIR@|${INCLUDE_DIR}|" -e "s|@LIB_DIR@|${LIB_DIR}|" \
		-e "s|@LIBCHROME_VERS@|${LIBCHROME_VERS}|" \
		"${in_pc_file}" > "${out_pc_file}"
	insinto "${LIB_DIR}/pkgconfig"
	doins "${out_pc_file}"
}

platform_pkg_test() {
	local test_bin
	if [[ -z "${CROS_CAMERA_TESTS}" ]]; then
		return
	fi
	for test_bin in ${CROS_CAMERA_TESTS}; do
		platform_test "run" "${OUT}/${test_bin}"
	done
}

EXPORT_FUNCTIONS src_unpack
