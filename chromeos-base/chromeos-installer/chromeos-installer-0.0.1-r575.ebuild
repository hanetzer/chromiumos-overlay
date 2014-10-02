# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="550bb7e7722125d1d83c4a29c03a44b283523b64"
CROS_WORKON_TREE="edf6d9d6dbc269a07c644d376f616c8c80d345c0"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_DESTDIR="${S}"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-workon cros-debug cros-au

DESCRIPTION="Chrome OS Installer"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="32bit_au cros_host pam test"

DEPEND="
	chromeos-base/verity[32bit_au=]
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
	chromeos-base/vboot_reference[32bit_au=]
	dev-util/shflags
	sys-apps/rootdev
	sys-apps/util-linux
	sys-apps/which
	sys-fs/e2fsprogs
	!<chromeos-base/chromeos-init-0.0.15"

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

	insinto /usr/share/misc
	doins share/chromeos-common.sh

	insinto /etc/init
	doins init/*.conf
}
