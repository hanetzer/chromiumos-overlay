# Copyright 2010 Chromium OS Authors
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4
CROS_WORKON_COMMIT="c1fe06a2b49a0053c9ae0c2465059e103acc622a"
CROS_WORKON_TREE="fbc5d0c2a52e58f88367c1958d605246bb46db05"
CROS_WORKON_PROJECT="chromiumos/third_party/coreboot"
CROS_WORKON_LOCALNAME="coreboot"

inherit cros-workon toolchain-funcs

DESCRIPTION="Superiotool allows you to detect which Super I/O you have on your mainboard, and it can provide detailed information about the register contents of the Super I/O."
HOMEPAGE="http://www.coreboot.org/Superiotool"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"

RDEPEND="sys-apps/pciutils"
DEPEND="${RDEPEND}"

src_compile() {
	emake -C util/superiotool CC="$(tc-getCC)"
}

src_install() {
	emake -C util/superiotool DESTDIR="${D}" install
}
