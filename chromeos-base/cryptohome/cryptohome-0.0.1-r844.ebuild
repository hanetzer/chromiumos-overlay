# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="eea56c9f7073f56e09dad8ea22ce3861c5c8fe44"
CROS_WORKON_TREE="168a3d9c5b9aa5696afedb93601fb63b5ba548e8"
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
IUSE="test -tpm2"

RDEPEND="
	!chromeos-base/chromeos-cryptohome
	!tpm2? (
		app-crypt/trousers
	)
	tpm2? (
		chromeos-base/trunks
	)
	chromeos-base/chaps
	chromeos-base/libchromeos
	chromeos-base/libscrypt
	chromeos-base/metrics
	dev-libs/dbus-glib
	dev-libs/glib
	dev-libs/openssl
	dev-libs/protobuf
	sys-apps/keyutils
	sys-fs/ecryptfs-utils
	sys-fs/lvm2
"
DEPEND="${RDEPEND}
	chromeos-base/system_api
	chromeos-base/vboot_reference
	dev-cpp/gtest
"

src_install() {
	pushd "${OUT}" >/dev/null
	dosbin cryptohomed cryptohome cryptohome-path lockbox-cache tpm-manager
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
