# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

DESCRIPTION="The Chinese PinYin and Bopomofo conversion library."
HOMEPAGE="http://code.google.com/p/pyzy/"
SRC_URI="http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/pyzy-${PV}.tar.gz"
LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE=""
RDEPEND=">=dev-db/sqlite-3.6.18
	>=dev-libs/glib-2.24"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	>=sys-devel/gettext-0.16.1"
