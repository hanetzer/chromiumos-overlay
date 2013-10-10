# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="a2ed26bf189da1b2b09a5fc6da6ea4bef861d895"
CROS_WORKON_TREE="9fdb1add4769157be0e426c76f3c0f1dae470588"
CROS_WORKON_PROJECT="chromiumos/platform/cryptohome"
CROS_WORKON_LOCALNAME="cryptohome"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-debug cros-workon

DESCRIPTION="Encrypted home directories for Chromium OS"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="test"

RDEPEND="
	app-crypt/trousers
	chromeos-base/chaps
	chromeos-base/platform2
	chromeos-base/libchromeos
	chromeos-base/libscrypt
	dev-libs/dbus-glib
	dev-libs/glib
	dev-libs/nss
	dev-libs/openssl
	dev-libs/protobuf
	sys-apps/keyutils
	sys-fs/ecryptfs-utils"

DEPEND="
	chromeos-base/system_api
	test? ( dev-cpp/gtest )
	chromeos-base/libchrome:180609[cros-debug=]
	chromeos-base/vboot_reference
	${RDEPEND}"

src_prepare() {
	cros-workon_src_prepare
}

src_configure() {
	cros-workon_src_configure
}

src_compile() {
	cros-workon_src_compile
}

src_test() {
	# Needed for `cros_run_unit_tests`.
	cros-workon_src_test
}

src_install() {
	cros-workon_src_install
	pushd "${OUT}" >/dev/null
	dosbin cryptohomed cryptohome cryptohome-path lockbox-cache
	dosbin mount-encrypted
	popd >/dev/null

	dobin email_to_image

	insinto /etc/dbus-1/system.d
	doins etc/Cryptohome.conf

	insinto /usr/share/dbus-1/services/
	doins share/org.chromium.Cryptohome.service
}
