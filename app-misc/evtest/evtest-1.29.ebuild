# Copyright 2014 The Chromium OS Authors. All rights reserved.  1
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

inherit autotools eutils

DESCRIPTION="A test program for capturing input device events."
HOMEPAGE="http://cgit.freedesktop.org/evtest/"
SRC_URI="http://cgit.freedesktop.org/evtest/snapshot/${P}.tar.bz2
	mirror://gentoo/${P}-mans.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="+xml"

# We bundled the man pages ourselves to avoid xmlto/asciidoc.
# We need libxml2 for the capture tool.  While at runtime,
# we have a file that can be used with xsltproc, we don't
# directly need it ourselves, so don't depend on libxslt.
RDEPEND="xml? ( dev-libs/libxml2 )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

src_prepare() {
	# No pretty configure flag :/
	sed -i -r \
		-e "s:HAVE_LIBXML=(yes|no):HAVE_LIBXML=$(usex xml):g" \
		configure.ac || die

	# We pre-compile the man pages.
	export XMLTO=/bin/true ASCIIDOC=/bin/true

	epatch "${FILESDIR}/1.29-add-grab-flag.patch"
	eautoreconf
}
