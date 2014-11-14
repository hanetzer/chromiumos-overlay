# Copyright 2010 Chromium OS Authors
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

CROS_WORKON_COMMIT="8ac8ff28bab1337782e8694275bb2c644b86f38a"
CROS_WORKON_TREE="c3c14a8c6b79573b3e9cc9f0aaccbecdfc1b0979"
inherit cros-workon toolchain-funcs

DESCRIPTION="Superiotool allows you to detect which Super I/O you have on your mainboard, and it can provide detailed information about the register contents of the Super I/O."
HOMEPAGE="http://www.coreboot.org/Superiotool"

CROS_WORKON_PROJECT="chromiumos/third_party/coreboot"
CROS_WORKON_LOCALNAME="coreboot"

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
