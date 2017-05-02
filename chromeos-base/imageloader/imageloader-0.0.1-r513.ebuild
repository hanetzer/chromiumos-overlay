# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT=("c03c9de10c11795a7ea5197956ffbf71646a0702" "d80e3eca9bbd0b0e9dbd26f39a018f02f224d45a")
CROS_WORKON_TREE=("41a4c7da75b358ed99ce60a662b9eb3bd9c7687a" "78a8b1f4b037e5474b0cc6e6d9790ac36a8fb5a1")
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
IUSE=""

RDEPEND="chromeos-base/libbrillo
	dev-libs/openssl"

DEPEND="${RDEPEND}"

src_unpack() {
	local s="${S}"
	platform_src_unpack
	# look in src/platform
	S="${s}/platform/imageloader"
}

src_install() {
	# Install seccomp policy file.
	insinto /opt/google/imageloader
	newins "seccomp/imageloader-seccomp-${ARCH}.policy" imageloader-seccomp.policy
	newins "seccomp/imageloader-helper-seccomp-${ARCH}.policy" imageloader-helper-seccomp.policy
	cd "${OUT}"
	dosbin imageloader
	cd "${S}"
	dosbin imageloader_wrapper
	insinto /etc/dbus-1/system.d
	doins dbus_permissions/org.chromium.ImageLoader.conf
	insinto /usr/share/dbus-1/system-services
	doins dbus_service/org.chromium.ImageLoader.service
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
