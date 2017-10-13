# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="300354e5d74418c8e03737ca9029c64d9297a28d"
CROS_WORKON_TREE="9c07b02309289bb86367a8929c41cc7a53e2b78d"
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
