# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT=("b0f1d2f974675b78f8645e9dac5ad4e91f24810e" "36a28c557a29b01deccef42c565a8666ae1a5d22")
CROS_WORKON_TREE=("ac1a7035ef036014d565c91efa859d41c3ea0d97" "9653638da00a3b535624338966d97bc138e6b1e9")
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
	# Install seccomp policy file.
	insinto /opt/google/imageloader
	newins "imageloader-seccomp-${ARCH}.policy" imageloader-seccomp.policy
	cd "${OUT}"
	dosbin imageloader
	dobin imageloadclient
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
