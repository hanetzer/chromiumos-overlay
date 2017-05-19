# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="1b65449a647c99556511df30b8ab660b98acce7f"
CROS_WORKON_TREE="87376c438e0b25e971c5171ec94494031a31f658"
CROS_WORKON_PROJECT="chromiumos/platform/btsocket"
CROS_WORKON_LOCALNAME="../platform/btsocket"
PYTHON_DEPEND="2"

inherit cros-workon distutils python

DESCRIPTION="Bluetooth Socket support module"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="-asan"

DEPEND="dev-python/setuptools"
RDEPEND=""

src_configure() {
	asan-setup-env
	cros-workon_src_configure
}
