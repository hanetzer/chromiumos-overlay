# Copyright 2010 Google Inc.
# Distributed under the terms of the GNU General Public License v2
# $Header:

EAPI="2"
CROS_WORKON_COMMIT="1c9bc9cd04c0c6e303b57b29c92051b58d31d14e"
CROS_WORKON_PROJECT="chromiumos/third_party/flashrom"

inherit cros-workon toolchain-funcs

DESCRIPTION="Utility for reading, writing, erasing and verifying flash ROM chips"
HOMEPAGE="http://flashrom.org"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="ftdi serprog"

CROS_WORKON_LOCALNAME="flashrom"

RDEPEND="sys-apps/pciutils
	ftdi? ( dev-embedded/libftdi )"

src_compile() {
	if use arm; then
		emake CC="$(tc-getCC)" STRIP="" \
			CONFIG_OGP_SPI=no CONFIG_NICINTEL_SPI=no CONFIG_RAYER_SPI=no \
			CONFIG_NIC3COM=no CONFIG_NICREALTEK=no CONFIG_SATAMV=no ||
			die "emake failed"
	else
		emake CC="$(tc-getCC)" STRIP="" || die "emake failed"
	fi
}

src_install() {
	dosbin flashrom || die
	doman flashrom.8 || die
}
