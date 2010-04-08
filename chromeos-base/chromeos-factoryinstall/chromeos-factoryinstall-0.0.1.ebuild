# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

DESCRIPTION="Chrome OS Factory Installer"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="x86 arm"
IUSE=""

DEPEND=""

RDEPEND="chromeos-base/chromeos-installer
         chromeos-base/chromeos-init
         chromeos-base/memento_softwareupdate"

src_unpack() {
  local factory_installer="${CHROMEOS_ROOT}/src/platform/factory_installer"
  elog "Using factory_installer: $factory_installer"
  mkdir "${S}"
  cp -a "${factory_installer}"/* "${S}" || die
}

src_install() {
	insinto /etc/init
	doins factory_install.conf
	
	exeinto /usr/sbin
	doexe factory_install.sh
}
