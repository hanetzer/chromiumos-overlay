# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"
PYTHON_DEPEND="2"

inherit distutils eutils

DESCRIPTION="Python library for evdev bindings"
HOMEPAGE="http://gvalkov.github.com/python-evdev/"
SRC_URI="https://github.com/gvalkov/python-evdev/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="dev-python/setuptools"
RDEPEND=""

src_prepare() {
	epatch "${FILESDIR}/format.patch"
	distutils_src_prepare
}
