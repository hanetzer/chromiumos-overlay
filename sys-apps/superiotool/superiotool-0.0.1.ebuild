# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils toolchain-funcs

DESCRIPTION="Superiotool allows you to detect which Super I/O you have on your mainboard, and it can provide detailed information about the register contents of the Super I/O."
HOMEPAGE="http://www.coreboot.org/Superiotool"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86"
IUSE=""

SRC_URI=""
ESVN_REPO_URI="svn://coreboot.org/repos/trunk/util/${PN}"

DEPEND="extras? ( sys-apps/pciutils )"
RDEPEND="extras? ( sys-apps/pciutils )"

files="${CHROMEOS_ROOT}/src/third_party/superiotool-internal"

src_unpack() {
        elog "Source is stored in: ${files}"

        mkdir -p "${S}"
        cp -a "${files}"/* "${S}" || die "superiotool copy failed"

	cd ${S}
	sed -i \
		-e "s|-O2 -Wall -Werror -Wstrict-prototypes -Wundef -Wstrict-aliasing|${CFLAGS}|" \
		-e "s|-Werror-implicit-function-declaration -ansi||" \
		Makefile || die "sed"
}

src_compile() {
	emake CC="$(tc-getCC)" || die "emake failed"
}

src_install() {
	dobin superiotool
	doman *.8
}
