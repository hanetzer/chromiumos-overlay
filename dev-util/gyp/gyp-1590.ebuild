# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

PYTHON_COMPAT=( python2_7 )
inherit distutils-r1

DESCRIPTION="GYP, a tool to generates native build files"
HOMEPAGE="https://gyp.gsrc.io/"
SRC_URI="http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/${PN}-svn-${PV}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE=""

PATCHES=(
	"${FILESDIR}"/${P}-shlex-split-fix.patch
	"${FILESDIR}"/${P}-Avoid-gypd-infinite-recursion.patch
)
