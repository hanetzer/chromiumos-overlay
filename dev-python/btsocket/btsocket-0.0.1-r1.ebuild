# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="96927a43b3f0e3124bb278c1b73c461c7e651c3e"
CROS_WORKON_TREE="f9d290f474b49f683540a69c3feb34a8418f360f"
CROS_WORKON_PROJECT="chromiumos/platform/btsocket"
CROS_WORKON_LOCALNAME="../platform/btsocket"
PYTHON_DEPEND="2"

inherit cros-workon distutils python

DESCRIPTION="Bluetooth Socket support module"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-3"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

src_install() {
	# distutils.eclass doesn't allow us to install into /usr/local, so we
	# have to do this manually
	"$(PYTHON)" setup.py install --root="${D}" --prefix=/usr/local
	DISTUTILS_SRC_INSTALL_EXECUTED="1"
}
