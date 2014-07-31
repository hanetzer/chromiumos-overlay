# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
PYTHON_COMPAT=( python2_7 )

inherit distutils-r1 eutils

DESCRIPTION="Search for matches with a keyword tree"
HOMEPAGE="https://hkn.eecs.berkeley.edu/~dyoo/python/ahocorasick/"
SRC_URI="https://hkn.eecs.berkeley.edu/~dyoo/python/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE=""

DOCS="README LICENSE"

src_prepare() {
	epatch "${FILESDIR}/${P}-finite-tests.patch"
	epatch "${FILESDIR}/${P}-fix-warning.patch"
	epatch "${FILESDIR}/${P}-ssize_t-usage.patch"
	distutils-r1_src_prepare
}

python_test() {
	# These tests only check that the module doesn't crash and it is loadable.
	for test in test_dotty.py test_memleak.py test_memleak2.py test_memleak3.py; do
		echo "Testing $test"
		PYTHONPATH="$(find ${BUILD_DIR} -name lib\*)/ahocorasick" \
			python "$test" || die "Test $test failed."
	done
}
