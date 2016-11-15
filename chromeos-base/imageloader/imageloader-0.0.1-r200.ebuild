# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT=("a325861c8867fedc0e0039bf9f3f6de280bdd64a" "ad947558444c2eba74f0e1b02830eff71be9bf51")
CROS_WORKON_TREE=("439f31c4b4e57e2ee9dc8437fcf8b20f1f610517" "20cd7185558d73113584bb39be8090cd32cb18cd")
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

inherit cros-workon platform user

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
	# Install seccomp policy file.
	insinto /opt/google/imageloader
	newins "imageloader-seccomp-${ARCH}.policy" imageloader-seccomp.policy
	cd "${OUT}"
	dosbin imageloader
	cd "${S}"
	dosbin imageloader_wrapper
	insinto /etc/dbus-1/system.d
	doins org.chromium.ImageLoader.conf
	insinto /usr/share/dbus-1/system-services
	doins org.chromium.ImageLoader.service
	insinto /etc/init
	doins imageloader.conf
}

platform_pkg_test() {
	platform_test "run" "${OUT}/run_tests"
}

pkg_preinst() {
	enewuser "imageloaderd"
	enewgroup "imageloaderd"
}
