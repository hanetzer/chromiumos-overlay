# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="d1b808a6ae2ed0b9e50758c138dc0c563ec214f5"
CROS_WORKON_PROJECT="chromiumos/platform/crosutils"

inherit cros-workon

DESCRIPTION="Chromium OS build utilities"
HOMEPAGE="http://www.chromium.org/chromium-os"
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

DEPEND=""
RDEPEND="dev-libs/shflags
	dev-util/shflags"

CROS_WORKON_LOCALNAME="../scripts/"

src_configure() {
	find . -type l -exec rm {} \; &&
	rm -fr WATCHLISTS inherit-review-settings-ok lib/shflags ||
		die "Couldn't clean directory."
}

src_install() {
	# Install package files
	exeinto /usr/lib/crosutils
	doexe * || die "Could not install shared files."

	# Install python libraries into site-packages
	local python_version=$(/usr/bin/env python -c \
	      "import sys; print sys.version[:3]")
	insinto /usr/lib/python"${python_version}"/site-packages
	doins lib/*.py || die "Could not install python files."
	rm -f lib/*.py

	# Install libraries
	insinto /usr/lib/crosutils/lib
	doins lib/* || die "Could not install library files"

        doexe bin/loman.py || die "Could not install loman"
        dosym /usr/lib/crosutils/loman.py /usr/bin/loman
}
