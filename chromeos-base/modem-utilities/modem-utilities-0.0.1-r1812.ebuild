# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="1b7a8361db19bacf468e5b41ba79cf24c79f185d"
CROS_WORKON_TREE="fcea5d26e3aaf5cba64c1598ad8459b87ea2e9dd"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_DESTDIR="${S}"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-workon

DESCRIPTION="Chromium OS modem utilities"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	sys-apps/dbus
"

DEPEND="${RDEPEND}"

src_unpack() {
	cros-workon_src_unpack
	S+="/modem-utilities"
}
