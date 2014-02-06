# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="8929f308247f9075f6226415fd6dba3f75bf34f2"
CROS_WORKON_TREE="94b99abeb672a5545c199504f94cac334788be58"
CROS_WORKON_PROJECT="chromiumos/platform/cryptohome"
CROS_WORKON_LOCALNAME="cryptohome"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-debug cros-workon

DESCRIPTION="Encrypted home directories for Chromium OS"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="-asan -clang test"
REQUIRED_USE="asan? ( clang )"

RDEPEND="
	app-crypt/trousers
	chromeos-base/platform2
	chromeos-base/libscrypt
	dev-libs/dbus-glib
	dev-libs/glib
	dev-libs/nss
	dev-libs/openssl
	dev-libs/protobuf
	sys-apps/keyutils
	sys-fs/ecryptfs-utils"

DEPEND="
	test? ( dev-cpp/gtest )
	chromeos-base/libchrome:180609[cros-debug=]
	chromeos-base/vboot_reference
	${RDEPEND}"

src_prepare() {
	cros-workon_src_prepare
}

src_configure() {
	clang-setup-env
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
}
