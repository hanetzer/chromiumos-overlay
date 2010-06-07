# Copyright 2010 Google Inc.
# Distributed under the terms of the GNU General Public License v2
# $Header:

EAPI="2"

inherit toolchain-funcs git

DESCRIPTION="Utility for reading, writing, erasing and verifying flash ROM chips"
HOMEPAGE="http://flashrom.org"
EGIT_REPO_URI="http://src.chromium.org/git/flashrom.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="ftdi serprog"

RDEPEND="sys-apps/pciutils
	ftdi? ( dev-embedded/libftdi )"

src_compile() {
	emake CC="$(tc-getCC)" STRIP="" || die "emake failed"
}

src_install() {
	dosbin flashrom || die
	doman flashrom.8 || die
	dodoc ChangeLog README
}
