# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

inherit toolchain-funcs eutils

DESCRIPTION="Extended Display Identification Data (EDID) decoder"
HOMEPAGE="https://cgit.freedesktop.org/xorg/app/edid-decode"

# git archive --format=tar.gz --prefix=edid-decode-20170918/ f56f329ed23a25d002352dedba1e8f092a47286f -o edid-decode-20170918.tar.gz
SRC_URI="http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE=""

src_prepare() {
	epatch "${FILESDIR}/${PV}-add_cppflags_and_ldflags.patch"
}

src_configure() {
	tc-export CC
}
