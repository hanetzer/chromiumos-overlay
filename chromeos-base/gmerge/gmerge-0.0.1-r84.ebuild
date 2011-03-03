# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="2"
CROS_WORKON_COMMIT="f47f79ac35da89691d727b61cca32ad5f8661fed"

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
	dev-lang/python
	dev-libs/shflags
	sys-apps/portage"
DEPEND="${RDEPEND}"

src_install() {
  exeinto /usr/bin
  doexe gmerge
  doexe stateful_update
}

