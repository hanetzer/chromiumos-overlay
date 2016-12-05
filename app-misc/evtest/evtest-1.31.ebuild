# Copyright 2014 The Chromium OS Authors. All rights reserved.  1
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

inherit autotools eutils

DESCRIPTION="A test program for capturing input device events."
HOMEPAGE="http://cgit.freedesktop.org/evtest/"
SRC_URI="http://cgit.freedesktop.org/evtest/snapshot/${P}.tar.gz
	mirror://gentoo/${P}-mans.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="+xml"

# We bundled the man pages ourselves to avoid xmlto/asciidoc.
# We need libxml2 for the capture tool.  While at runtime,
# we have a file that can be used with xsltproc, we don't
# directly need it ourselves, so don't depend on libxslt.
# tar zcf ${P}-mans.tar.gz *.1 --transform=s:^:evtest-${P}/:
RDEPEND=""
DEPEND="${RDEPEND}
	virtual/pkgconfig"

S=${WORKDIR}/${PN}-${P}

src_prepare() {
	epatch "${FILESDIR}/1.29-add-grab-flag.patch"
	eautoreconf
}

src_configure() {
	# We pre-compile the man pages.
	XMLTO=$(type -P true) ASCIIDOC=$(type -P true) \
	econf
}
