# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="47c5743100ca13e62b59ed2b6f343c3d6a021084"
CROS_WORKON_TREE="0a84874221a8fbc479463956c8a89e481bedc1f8"
CROS_WORKON_PROJECT="chromiumos/platform/arc-camera"
CROS_WORKON_LOCALNAME="../platform/arc-camera"

inherit cros-debug cros-workon libchrome toolchain-funcs

DESCRIPTION="ARC camera HAL v3 service. The service is in charge of accessing
camera device. It uses unix domain socket to build a synchronous channel."

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="-asan -clang"
REQUIRED_USE="asan? ( clang )"

RDEPEND="
	chromeos-base/libbrillo
	chromeos-base/libmojo
	virtual/arc-camera3-hal"

DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_compile() {
	tc-export CC CXX PKG_CONFIG
	cros-debug-add-NDEBUG
	emake BASE_VER=${LIBCHROME_VERS} hal_adapter
}

src_install() {
	dobin hal_adapter/arc_camera3_service
}

src_test() {
	emake BASE_VER=${LIBCHROME_VERS} tests

	if use x86 || use amd64; then
		./common/future_unittest || die "future unit tests failed!"
	fi
}