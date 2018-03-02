# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="17f0102cf4c2ae0a9cf0c095c1b1e31f07a13d7d"
CROS_WORKON_TREE="d1ff027de443166f4935c120d7cfb7803bc8ff7f"
CROS_WORKON_PROJECT="chromiumos/platform/arc-camera"
CROS_WORKON_LOCALNAME="../platform/arc-camera"

inherit cros-constants cros-debug cros-workon libchrome toolchain-funcs user

DESCRIPTION="ARC camera HAL v3 service. The service is in charge of accessing
camera device. It uses unix domain socket to build a synchronous channel."

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="-asan cheets +arc-camera3-3a-sandbox"

RDEPEND="
	arc-camera3-3a-sandbox? ( media-libs/arc-camera3-libcab )
	chromeos-base/libbrillo
	!media-libs/arc-camera3-libsync
	media-libs/libsync
	virtual/arc-camera3-hal
	virtual/arc-camera3-hal-configs"

DEPEND="${RDEPEND}
	chromeos-base/libmojo
	media-libs/arc-camera3-android-headers
	media-libs/arc-camera3-libcamera_metadata
	media-libs/minigbm
	virtual/pkgconfig
	x11-libs/libdrm"

src_configure() {
	asan-setup-env
	cros-workon_src_configure
}

src_compile() {
	cw_emake BASE_VER=${LIBCHROME_VERS} hal_adapter
}

src_install() {
	local INCLUDE_DIR="/usr/include/arc"
	local LIB_DIR="/usr/$(get_libdir)"

	dobin hal_adapter/arc_camera3_service

	insinto /etc/init
	doins hal_adapter/init/camera-halv3-adapter.conf

	# Install seccomp policy file.
	insinto /usr/share/policy
	newins hal_adapter/seccomp_filter/camera-halv3-adapter-${ARCH}.policy camera-halv3-adapter.policy

	if use cheets; then
		insinto "${ARC_VENDOR_DIR}/etc/init"
		doins hal_adapter/init/init.camera.rc
	fi
}

pkg_preinst() {
	enewuser "arc-camera"
	enewgroup "arc-camera"
}
