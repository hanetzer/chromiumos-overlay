# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="2"
CROS_WORKON_COMMIT="f65f4b9f95f7ab49ba83aa0d6208de4ad2f2b624"

inherit cros-workon

DESCRIPTION="A util for installing packages using the CrOS dev server"
HOMEPAGE="http://www.chromium.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

CROS_WORKON_PROJECT="dev-util"
CROS_WORKON_LOCALNAME="dev"

RDEPEND="app-shells/bash
         app-portage/gentoolkit
         net-misc/wget"
DEPEND="${RDEPEND}"

src_install() {
  exeinto /usr/bin  
  doexe gmerge
  doexe stateful_update
}

