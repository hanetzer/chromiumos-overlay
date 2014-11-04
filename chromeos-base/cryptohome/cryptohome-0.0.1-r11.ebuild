# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="4ffaa83180b90b11ad1a8452bc7f7f84c85c02d8"
CROS_WORKON_TREE="28c42c8326489cc431010374b1dc2511b83a02c9"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_DESTDIR="${S}/platform2"

PLATFORM_NATIVE_TEST="yes"
PLATFORM_SUBDIR="cryptohome"

inherit cros-workon platform udev user

DESCRIPTION="Encrypted home directories for Chromium OS"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="test"

RDEPEND="
	!chromeos-base/chromeos-cryptohome
	app-crypt/trousers
	chromeos-base/chaps
	chromeos-base/libchromeos
	chromeos-base/libscrypt
	chromeos-base/metrics
	chromeos-base/platform2
	dev-libs/dbus-glib
	dev-libs/glib
	dev-libs/openssl
	dev-libs/protobuf
	sys-apps/keyutils
	sys-fs/ecryptfs-utils
	sys-fs/lvm2
"
DEPEND="${RDEPEND}
	test? ( dev-cpp/gtest )
	chromeos-base/system_api
	chromeos-base/vboot_reference
"

src_install() {
	pushd "${OUT}" >/dev/null
	dosbin cryptohomed cryptohome cryptohome-path lockbox-cache
	dosbin mount-encrypted
	popd >/dev/null

	insinto /etc/dbus-1/system.d
	doins etc/Cryptohome.conf

	insinto /etc/init
	doins init/*.conf
}

platform_pkg_test() {
	platform_test "run" "${OUT}/cryptohome_testrunner"
}
