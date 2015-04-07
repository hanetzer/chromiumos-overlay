# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="697f7b4d48990c50af56c99128a78fe554dacd1c"
CROS_WORKON_TREE="7e85091d732c2ce4402c734f30f81bec2c61c79e"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_DESTDIR="${S}"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-workon cros-debug cros-au libchrome

DESCRIPTION="Chrome OS Installer"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="32bit_au cros_host -mtd pam test"

DEPEND="
	chromeos-base/verity[32bit_au=]
	mtd? ( dev-embedded/android_mtdutils )
	test? (
		32bit_au? (
			dev-cpp/gmock32[32bit_au]
			dev-cpp/gtest32[32bit_au]
		)
		dev-cpp/gmock[static-libs(+)]
		dev-cpp/gtest[static-libs(+)]
	)
	!cros_host? (
		chromeos-base/vboot_reference[32bit_au=]
	)"
RDEPEND="
	pam? ( app-admin/sudo )
	chromeos-base/libchromeos
	chromeos-base/vboot_reference[32bit_au=]
	dev-util/shflags
	sys-apps/rootdev
	sys-apps/util-linux
	sys-apps/which
	sys-fs/e2fsprogs"

src_unpack() {
	cros-workon_src_unpack
	S+="/installer"
}

src_prepare() {
	cros-workon_src_prepare
}

src_configure() {
	# need this to get the verity headers working
	append-cppflags -I"${SYSROOT}"/usr/include/verity/
	append-cppflags -I"${SYSROOT}"/usr/include/vboot
	append-ldflags -L"${SYSROOT}"/usr/lib/vboot32

	use 32bit_au && board_setup_32bit_au_env
	cros-workon_src_configure
	use 32bit_au && board_teardown_32bit_au_env
}

src_compile() {
	# We don't need the installer in the sdk, just helper scripts.
	use cros_host && return 0

	use 32bit_au && board_setup_32bit_au_env
	USE_mtd=$(usev mtd) cros-workon_src_compile
	if use mtd; then
		USE_mtd=$(usev mtd) cw_emake -r nand_partition
	fi
	use 32bit_au && board_teardown_32bit_au_env
}

src_test() {
	use 32bit_au && board_setup_32bit_au_env
	# Needed for `cros_run_unit_tests`.
	cros-workon_src_test
	use 32bit_au && board_teardown_32bit_au_env
}

src_install() {
	cros-workon_src_install
	if use cros_host ; then
		dosbin chromeos-install
	else
		dobin "${OUT}"/cros_installer
		if use mtd ; then
			dobin "${OUT}"/nand_partition
		fi
		dosbin chromeos-* encrypted_import
		dosym usr/sbin/chromeos-postinst /postinst

		insinto /etc/init
		doins init/*.conf
	fi

	insinto /usr/share/misc
	doins share/chromeos-common.sh
}
