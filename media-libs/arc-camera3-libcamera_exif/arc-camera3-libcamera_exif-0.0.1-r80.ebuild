# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="97bd4b0fad241b04de891a9f76be435a54511b12"
CROS_WORKON_TREE="d52dea0b2c302e07802736ac00125bcec8fece2e"
CROS_WORKON_PROJECT="chromiumos/platform/arc-camera"
CROS_WORKON_LOCALNAME="../platform/arc-camera"

inherit cros-debug cros-workon libchrome toolchain-funcs

DESCRIPTION="ARC camera HAL v3 exif util."

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="-asan"

RDEPEND="media-libs/libexif"

DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_configure() {
	asan-setup-env
	cros-workon_src_configure
}

src_compile() {
	cw_emake BASE_VER=${LIBCHROME_VERS} libcamera_exif
}

src_install() {
	local INCLUDE_DIR="/usr/include/arc"
	local LIB_DIR="/usr/$(get_libdir)"

	dolib.so common/libcamera_exif.so

	insinto "${INCLUDE_DIR}"
	doins include/arc/exif_utils.h

	sed -e "s|@INCLUDE_DIR@|${INCLUDE_DIR}|" -e "s|@LIB_DIR@|${LIB_DIR}|" \
		-e "s|@LIBCHROME_VERS@|${LIBCHROME_VERS}|" \
		common/libcamera_exif.pc.template > common/libcamera_exif.pc
	insinto "${LIB_DIR}/pkgconfig"
	doins common/libcamera_exif.pc
}
