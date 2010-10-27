# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="1dd9932b1d68cf053f25c3d131d173a8d5930af9"

inherit cros-workon

DESCRIPTION="Chrome OS Installer"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="-minimal"

DEPEND="!!<=dev-util/crosutils-0.0.1-r1"

# TODO(adlr): remove coreutils dep if we move to busybox
RDEPEND="app-arch/gzip
         dev-libs/shflags
         sys-apps/coreutils
         sys-apps/util-linux
         sys-fs/dosfstools
         sys-fs/e2fsprogs"

CROS_WORKON_LOCALNAME="installer"
CROS_WORKON_PROJECT="installer"

src_install() {
	if use minimal ; then
		exeinto /usr/sbin
		doexe "${S}"/chromeos-*
		dosym usr/sbin/chromeos-postinst /postinst
	else
	# Copy chromeos-* scripts to /usr/lib/installer/ on host.
		exeinto /usr/lib/installer
		doexe "${S}"/chromeos-*
		dosym usr/lib/installer/chromeos-postinst /postinst

		# Copy bin/* scripts to /usr/bin/ on host.
		exeinto /usr/bin
		doexe "${S}"/bin/*

		# Copy mod_for_test_scripts/* scripts to
		# /usr/share/chromeos-installer/mod_for_test_scripts on host.
		exeinto /usr/share/chromeos-installer/mod_for_test_scripts
		doexe "${S}"/mod_for_test_scripts/*

		# Copy mod_for_test_scripts/ssh_keys/* to
		# /usr/share/chromeos-installer/mod_for_test_scripts/ssh_keys on host.
		# Unfortunately, doexe does not support a recursive flag :-(
		exeinto /usr/share/chromeos-installer/mod_for_test_scripts/ssh_keys
		doexe "${S}"/mod_for_test_scripts/ssh_keys/*

		# Copy mod_for_factory_scripts/* scripts to
		# /usr/share/chromeos-installer/mod_for_factory_scripts on host.
		exeinto /usr/share/chromeos-installer/mod_for_factory_scripts
		doexe "${S}"/mod_for_factory_scripts/*
	fi
}
