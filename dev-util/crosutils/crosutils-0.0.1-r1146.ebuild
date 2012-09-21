# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT=4411efeb87635fe2bd751cebef9f1a7be474bb44
CROS_WORKON_TREE="473afe5ad79ed71ab820874a30d63d8dd2d7e8f7"

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
}
