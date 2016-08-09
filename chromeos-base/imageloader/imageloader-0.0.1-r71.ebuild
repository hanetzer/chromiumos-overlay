# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT=("c99d8fb45362e01973a573bde469bf59bc4cdbd5" "fb7fe28f7f7e948d6ce4c8e9b1ba9c3999c819ac")
CROS_WORKON_TREE=("167191a344bdf2e8aa3c337bb758647929379e42" "385f333de9c877b006f09a28a86992d56ebc65e1")
CROS_WORKON_LOCALNAME=(
	"platform2"
	"platform/imageloader"
)
CROS_WORKON_PROJECT=(
	"chromiumos/platform2"
	"chromiumos/platform/imageloader"
)
CROS_WORKON_DESTDIR=(
	"${S}/platform2"
	"${S}/platform/imageloader"
)
PLATFORM_SUBDIR="imageloader"

inherit cros-workon platform

DESCRIPTION="Allow mounting verified utility images"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="test"

RDEPEND="chromeos-base/libbrillo
	dev-libs/dbus-c++
	dev-libs/openssl"

DEPEND="${RDEPEND}
	test? (
		dev-cpp/gtest
	)"

src_unpack() {
	local s="${S}"
	platform_src_unpack
	# look in src/platform
	S="${s}/platform/imageloader"
}

src_install() {
	cd "${OUT}"
	dosbin imageloader
	dobin imageloadclient
	cd "${S}"
	insinto /etc/dbus-1/system.d
	doins org.chromium.ImageLoader.conf
	insinto /usr/share/dbus-1/system-services
	doins org.chromium.ImageLoader.service
}

platform_pkg_test() {
	platform_test "run" "${OUT}/run_tests"
}
