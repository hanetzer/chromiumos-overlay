# Copyright 2010 Chromium OS Authors
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

CROS_WORKON_COMMIT="b71530edf3a37a880948223d7326e9b44c95c1a7"
CROS_WORKON_TREE="f624f001a96e54b4ef4bb18a2bc6c43a59d26757"
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
