# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="06c4626e7b09e70876c3d4bb917bc75cc5d39639"
CROS_WORKON_TREE="9170346b1a7f880d738cdea6692c9b7d05d2c07e"
CROS_WORKON_PROJECT="chromiumos/platform/btsocket"
CROS_WORKON_LOCALNAME="../platform/btsocket"
PYTHON_DEPEND="2"

inherit cros-workon distutils python

DESCRIPTION="Bluetooth Socket support module"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="-asan -clang"
REQUIRED_USE="asan? ( clang )"

DEPEND="dev-python/setuptools"
RDEPEND=""

src_configure() {
	clang-setup-env
	cros-workon_src_configure
}
