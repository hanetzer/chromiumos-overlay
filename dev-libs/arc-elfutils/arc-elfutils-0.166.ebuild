# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"

P=${P#"arc-"}
PN=${PN#"arc-"}
S="${WORKDIR}/${P}"

inherit eutils flag-o-matic autotools multilib-minimal arc-build

DESCRIPTION="Libraries/utilities to handle ELF objects (ARC ebuild only includes libelf)"
HOMEPAGE="https://fedorahosted.org/elfutils/"
SRC_URI="https://fedorahosted.org/releases/e/l/${PN}/${PV}/${P}.tar.bz2"

LICENSE="GPL-2-with-exceptions"
SLOT="0"
KEYWORDS="*"
IUSE="+static-libs -shared-libs test"

src_prepare() {
	epatch "${FILESDIR}"/${PN#"arc-"}-0.118-PaX-support.patch
	epatch "${FILESDIR}"/${PN#"arc-"}-0.166-fix-strtab-mismatch.patch
	epatch "${FILESDIR}"/${PN}-0.166-bionic-fixup.patch
	use static-libs || sed -i -e '/^lib_LIBRARIES/s:=.*:=:' -e '/^%.os/s:%.o$::' lib{asm,dw,elf}/Makefile.in
	sed -i 's:-Werror::' */Makefile.in
	# some patches touch both configure and configure.ac
	find -type f -exec touch -r configure {} +

	eautoreconf
}

src_configure() {
	arc-build-select-gcc

	use test && append-flags -g #407135
	multilib-minimal_src_configure
}

multilib_src_configure() {
	ECONF_SOURCE="${S}" econf \
		--prefix="${ARC_PREFIX}/vendor" \
		--disable-nls \
		--disable-thread-safety \
		--program-prefix="eu-" \
		--without-bzlib \
		--without-lzma
}

multilib_src_compile() {
	emake -C libelf
}

multilib_src_install() {
	emake DESTDIR="${D}" -C libelf install

	use shared-libs || rm -f "${D}/${ARC_PREFIX}/vendor/$(get_libdir)/"*.so*

	# elf.h doesn't get installed by make install.
	insinto "${ARC_PREFIX}/vendor/include"
	doins "${S}/libelf/elf.h"

	insinto "${ARC_PREFIX}/vendor/$(get_libdir)/pkgconfig"
	doins config/libelf.pc
}
