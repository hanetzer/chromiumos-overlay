# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT=("bc81a74d651cf9f74154a8da9330e8dcdc714828" "d5eb65afd5f9da10a3fa86f65d357a817221717e")
CROS_WORKON_TREE=("82c557a1ec791be212766233c901a36e0311ef1c" "fb3490768a3a1070a8acc1987381828de52d7beb")
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

RDEPEND="dev-libs/dbus-c++"
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
