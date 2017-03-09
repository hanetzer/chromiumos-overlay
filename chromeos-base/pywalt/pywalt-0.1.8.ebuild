# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

PYTHON_COMPAT=( python{2_7,3_{3,4,5}} )

inherit distutils-r1

DESCRIPTION="WALT - Python scripts"
HOMEPAGE="https://github.com/google/walt"
SRC_URI="https://github.com/google/walt/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="dev-python/numpy"
DEPEND=""

S="${WORKDIR}/walt-${PV}/${PN}"
