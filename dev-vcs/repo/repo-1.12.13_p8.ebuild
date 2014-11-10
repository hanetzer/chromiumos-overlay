# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

PYTHON_COMPAT=( python2_7 )
inherit python-single-r1

DESCRIPTION="Tool for managing many Git repositories and integrating with Gerrit."
HOMEPAGE="https://code.google.com/p/git-repo/"

MY_PV=${PV/_p/-cr}
SRC_URI="https://chromium.googlesource.com/external/repo/+archive/v${MY_PV}.tar.gz -> ${PN}-${MY_PV}.tar.gz"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
S=${WORKDIR}

src_install() {
	dobin repo
}