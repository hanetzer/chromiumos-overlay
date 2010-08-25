# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="5ddfb0a9e5a9da683be412812106aacebc84cc9e"

inherit cros-workon

DESCRIPTION="Chrome OS Installer"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="-minimal"

DEPEND=""

# TODO(adlr): remove coreutils dep if we move to busybox
RDEPEND="dev-libs/shflags
         sys-apps/coreutils
         sys-apps/util-linux
         sys-fs/e2fsprogs"

CROS_WORKON_LOCALNAME="installer"
CROS_WORKON_PROJECT="installer"

src_install() {
  exeinto /usr/sbin
  doexe "${S}"/chromeos-*
  dosym usr/sbin/chromeos-postinst /postinst

  if ! use minimal ; then
    # Copy bin/* scripts to /usr/sbin/ on host.
    exeinto /usr/sbin
    doexe "${S}"/bin/*

    # Copy mod_for_test_scripts/* scripts to
    # /usr/share/chromeos-installer/mod_for_test_scripts on host.
    exeinto /usr/share/chromeos-installer/mod_for_test_scripts
    doexe "${S}"/mod_for_test_scripts/*

    # Copy mod_for_factory_scripts/* scripts to
    # /usr/share/chromeos-installer/mod_for_factory_scripts on host.
    exeinto /usr/share/chromeos-installer/mod_for_factory_scripts
    doexe "${S}"/mod_for_factory_scripts/*
  fi
}
