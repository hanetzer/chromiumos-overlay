# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

PYTHON_COMPAT=( python2_7 )
inherit python-single-r1

MY_PV=${PV/_p/-cr}

DESCRIPTION="Tool for managing many Git repositories and integrating with Gerrit"
HOMEPAGE="https://gerrit.googlesource.com/git-repo"
SRC_URI="https://chromium.googlesource.com/external/repo/+archive/v${MY_PV}.tar.gz -> ${PN}-${MY_PV}.tar.gz"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

S=${WORKDIR}

src_install() {
	dobin repo
}
