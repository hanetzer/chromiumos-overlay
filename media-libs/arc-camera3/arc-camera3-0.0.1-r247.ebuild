# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="54b0e9c4191a67b45bbb1a19ed214535829889c1"
CROS_WORKON_TREE="79eae1be6ad32a7c68d5a0378fc61ed7ec8c0edf"
CROS_WORKON_PROJECT="chromiumos/platform/arc-camera"
CROS_WORKON_LOCALNAME="../platform/arc-camera"

inherit cros-debug cros-workon libchrome toolchain-funcs

DESCRIPTION="ARC camera HAL v3 service. The service is in charge of accessing
camera device. It uses unix domain socket to build a synchronous channel."

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="-asan cheets arc-camera3-3a-sandbox"

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
		insinto /opt/google/containers/android/vendor/etc/init
		doins hal_adapter/init/init.camera.rc
	fi
}