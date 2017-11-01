# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT=("f5ed93fdcc95af8043c4117b6cdee110e9706f35" "b076fef1a86edcf6579df85e97a5653646a92073")
CROS_WORKON_TREE=("4b29a126ea37dd86c627dfc4052aea1e2dcf4587" "ede617fdc306dc37f9839423d3dc9488840eaff4")
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
	dev-libs/openssl
	sys-fs/lvm2"

DEPEND="${RDEPEND}
	chromeos-base/system_api"

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
	doins imageloader-shutdown.conf
}

platform_pkg_test() {
	platform_test "run" "${OUT}/run_tests"
}

pkg_preinst() {
	enewuser "imageloaderd"
	enewgroup "imageloaderd"
}
