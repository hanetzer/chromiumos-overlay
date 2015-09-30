# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

inherit multilib

DESCRIPTION="Small XZ decompressor"
HOMEPAGE="http://tukaani.org/xz/embedded.html"
SRC_URI="http://tukaani.org/xz/xz-embedded-${PV}.tar.gz"

# See top-level COPYING file for the license description.
LICENSE="public-domain"
SLOT="0"
KEYWORDS="*"
IUSE=""

src_unpack() {
	default
	cp "${FILESDIR}"/{Makefile,xz-embedded.pc.in} "${S}" || die "Copying files"
}

src_configure() {
	export GENTOO_LIBDIR=$(get_libdir)
	tc-export AR CC
}
