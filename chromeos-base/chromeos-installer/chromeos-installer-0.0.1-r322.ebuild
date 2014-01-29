# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="bf0ac16bc02b41401e6bd6aafc94dc62ceeb681a"
CROS_WORKON_TREE="305b4bf3bdd256f7800392586f63b112ed196a5a"
CROS_WORKON_PROJECT="chromiumos/platform/installer"
CROS_WORKON_LOCALNAME="installer"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-workon cros-debug cros-au

DESCRIPTION="Chrome OS Installer"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"
IUSE="32bit_au cros_host pam"

DEPEND="
	chromeos-base/verity
	dev-cpp/gmock
	!cros_host? (
		chromeos-base/vboot_reference
	)"
RDEPEND="
	pam? ( app-admin/sudo )
	chromeos-base/vboot_reference
	dev-util/shflags
	sys-apps/rootdev
	sys-apps/util-linux
	sys-apps/which
	sys-block/parted
	sys-fs/e2fsprogs"

src_prepare() {
	cros-workon_src_prepare
}

src_configure() {
	# need this to get the verity headers working
	append-cxxflags -I"${SYSROOT}"/usr/include/verity/
	append-cxxflags -I"${SYSROOT}"/usr/include/vboot
	append-ldflags -L"${SYSROOT}"/usr/lib/vboot32

	use 32bit_au && board_setup_32bit_au_env

	cros-workon_src_configure
}

src_compile() {
	# We don't need the installer in the sdk, just helper scripts.
	use cros_host && return 0

	cros-workon_src_compile
}

src_test() {
	# Needed for `cros_run_unit_tests`.
	cros-workon_src_test
}

src_install() {
	cros-workon_src_install
	local path
	if use cros_host ; then
		# Copy chromeos-* scripts to /usr/lib/installer/ on host.
		path="usr/lib/installer"
	else
		path="usr/sbin"
		dobin "${OUT}"/cros_installer
		dosym ${path}/chromeos-postinst /postinst
	fi

	exeinto /${path}
	doexe chromeos-* encrypted_import

	insinto /etc/init
	doins crx-import.conf
}
