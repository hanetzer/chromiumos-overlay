# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="4d21a2926a2e10a438f22f874108712c3c0d4779"
CROS_WORKON_TREE="4670bdeec4c356938b692e53594dd42090820420"

EAPI=2
CROS_WORKON_PROJECT="chromiumos/platform/crosutils"
CROS_WORKON_LOCALNAME="../scripts/"

inherit python cros-workon

DESCRIPTION="Chromium OS build utilities"
HOMEPAGE="http://www.chromium.org/chromium-os"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

src_configure() {
	find . -type l -exec rm {} \; &&
	rm -fr WATCHLISTS inherit-review-settings-ok lib/shflags ||
		die "Couldn't clean directory."
}

src_install() {
	# Install package files
	exeinto /usr/lib/crosutils
	doexe * || die "Could not install shared files."

	insinto "$(python_get_sitedir)"
	doins lib/*.py || die "Could not install python files."
	rm -f lib/*.py

	# Install libraries
	insinto /usr/lib/crosutils/lib
	doins lib/* || die "Could not install library files"

	doexe bin/loman.py || die "Could not install loman"
	dosym /usr/lib/crosutils/loman.py /usr/bin/loman
}
