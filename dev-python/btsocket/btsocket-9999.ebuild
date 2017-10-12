# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"
CROS_WORKON_PROJECT="chromiumos/platform/btsocket"
CROS_WORKON_LOCALNAME="../platform/btsocket"

PYTHON_COMPAT=( python2_7 )

inherit cros-workon distutils-r1

DESCRIPTION="Bluetooth Socket support module"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="~*"
IUSE="-asan"

DEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"
RDEPEND=""

src_configure() {
	asan-setup-env
	cros-workon_src_configure
}
