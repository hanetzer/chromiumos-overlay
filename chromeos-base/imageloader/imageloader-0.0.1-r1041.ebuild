# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT=("2873587ed1df72fc7e363e20f3e57cec3d4a59fa" "1c3fbed9123c081c73b1bc97f755ccf7a753b74d")
CROS_WORKON_TREE=("5232c4c4c545c2c5f1728826a0a4894fb36d09a6" "26a3051c85d5401290a097eb6b9266af8b8d0864")
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
