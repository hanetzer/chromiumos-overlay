# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="2"

DESCRIPTION="A util for installing packages using the CrOS dev server"
HOMEPAGE="http://www.chromium.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="arm x86"
IUSE=""

RDEPEND="app-shells/bash
         app-portage/gentoolkit
         net-misc/wget"
DEPEND="${RDEPEND}"

src_install() {
  local devserver="${CHROMEOS_ROOT}/src/platform/dev"
  exeinto /usr/bin  
  doexe "${devserver}"/gmerge
  doexe "${devserver}"/stateful_update
}

