# Copyright 2010 Chromium OS Authors
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

CROS_WORKON_COMMIT="e9d953283a5b43bf967128ca73db0e90c2df32df"
CROS_WORKON_TREE="690c33867a4471c53337e8ac37bf99ce3bf03c07"
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
