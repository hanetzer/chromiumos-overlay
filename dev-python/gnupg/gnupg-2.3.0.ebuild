# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
PYTHON_COMPAT=( python2_7 python3_{3,4} pypy )

inherit distutils-r1

DESCRIPTION="A Python wrapper for GnuPG"
HOMEPAGE="https://pypi.python.org/pypi/gnupg/"
SRC_URI="mirror://pypi/${P:0:1}/${PN}/${P}.tar.gz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND=">=dev-python/psutil-1.2.1[${PYTHON_USEDEP}]"
RDEPEND="${DEPEND}
	app-crypt/gnupg
	!dev-python/python-gnupg"
