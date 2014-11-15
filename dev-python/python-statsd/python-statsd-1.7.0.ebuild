# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

PYTHON_COMPAT=( python2_7 )

inherit distutils-r1 eutils

DESCRIPTION="A Python client for statsd"
HOMEPAGE="https://pypi.python.org/pypi/python-statsd https://github.com/WoLpH/python-statsd"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
# Upstream does not have the default DOCS expected by distutils.
DOCS=""

DEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"
RDEPEND=""

src_prepare () {
	epatch "${FILESDIR}"/${P}-skip-tests-in-install.patch
}
