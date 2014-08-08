# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="f5a3e5ec26dde5ee00d1f9a1f7ef1060e5187492"
CROS_WORKON_TREE="18e2e29d92768e2855a5f456ce42ffd3c095d4f4"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_DESTDIR="${S}"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-debug cros-workon libchrome

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
	sys-fs/lvm2"

DEPEND="
	test? ( dev-cpp/gtest )
	chromeos-base/system_api
	chromeos-base/vboot_reference
	${RDEPEND}"

src_unpack() {
	cros-workon_src_unpack
	S+="/cryptohome"
}

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

	insinto /etc/init
	doins init/*.conf
}
