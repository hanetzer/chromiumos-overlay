# Copyright 2010 Google Inc.
# Distributed under the terms of the GNU General Public License v2
# $Header:

EAPI="2"
CROS_WORKON_COMMIT="cce56d5b5f6b5a4e93bfc97a7af7449d8bf5b2d4"

inherit cros-workon toolchain-funcs

DESCRIPTION="Utility for reading, writing, erasing and verifying flash ROM chips"
HOMEPAGE="http://flashrom.org"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="ftdi serprog"

CROS_WORKON_LOCALNAME="flashrom"
CROS_WORKON_PROJECT="flashrom"

RDEPEND="sys-apps/pciutils
	ftdi? ( dev-embedded/libftdi )"

src_compile() {
	emake CC="$(tc-getCC)" STRIP="" || die "emake failed"
}

src_install() {
	dosbin flashrom || die
	doman flashrom.8 || die
}
