# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT=("41ec8e520d723f124458d76eb48e43d8c584d867" "d5eb65afd5f9da10a3fa86f65d357a817221717e")
CROS_WORKON_TREE=("2c26422bb18b003418625e8a4aa1e40bd6b4ef8f" "fb3490768a3a1070a8acc1987381828de52d7beb")
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
