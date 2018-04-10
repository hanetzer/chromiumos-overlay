# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="8dd6e321c24df42159fd55d71cd69c7484a0f09c"
CROS_WORKON_TREE="f607ab3ff14944e374e24fb445aadabe1e6fd869"
CROS_WORKON_PROJECT="chromiumos/platform/arc-camera"
CROS_WORKON_LOCALNAME="../platform/arc-camera"

inherit cros-debug cros-workon libchrome toolchain-funcs

DESCRIPTION="Chrome OS HAL IPC util."

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="-asan"

RDEPEND=""

DEPEND="${RDEPEND}
	chromeos-base/libmojo
	media-libs/cros-camera-libcamera_metadata
	virtual/pkgconfig"

src_configure() {
	cros-workon_src_configure
}

src_compile() {
	asan-setup-env
	cw_emake BASE_VER=${LIBCHROME_VERS} libcamera_ipc
}

src_install() {
	local INCLUDE_DIR="/usr/include/cros-camera"
	local LIB_DIR="/usr/$(get_libdir)"

	dolib.a common/libcamera_ipc.pic.a
	# install all mojom header files to the relative directories.
	local mojom_headers=`find mojo/ -name "*.h" -type f`
	for f in ${mojom_headers}
	do
		local dir=`dirname $f`
		insinto "/usr/include/${dir}"
		doins $f
	done

	insinto "${INCLUDE_DIR}"
	doins include/cros-camera/camera_mojo_channel_manager.h
	doins include/cros-camera/ipc_util.h

	sed -e "s|@INCLUDE_DIR@|${INCLUDE_DIR}|" -e "s|@LIB_DIR@|${LIB_DIR}|" \
		-e "s|@LIBCHROME_VERS@|${LIBCHROME_VERS}|" \
		common/libcamera_ipc.pc.template > common/libcamera_ipc.pc
	insinto "${LIB_DIR}/pkgconfig"
	doins common/libcamera_ipc.pc
}
