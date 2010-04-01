# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/perf/perf-2.6.32.ebuild,v 1.1 2009/12/04 16:33:24 flameeyes Exp $

EAPI=2

inherit eutils toolchain-funcs linux-info

DESCRIPTION="Userland tools for Linux Performance Counters"
HOMEPAGE="http://perf.wiki.kernel.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE="+demangle +doc"

RDEPEND="demangle? ( sys-devel/binutils )
	dev-libs/elfutils"
DEPEND="${RDEPEND}
	doc? ( app-text/asciidoc app-text/xmlto )"

kernel=${CHROMEOS_KERNEL:-"kernel/files"}
files="${CHROMEOS_ROOT}/src/third_party/${kernel}/"

src_unpack() {
	elog "Using kernel files: ${files}"

	mkdir -p "${S}"
	cp -ar "${files}"/* "${S}" || die
}

src_compile() {
	local makeargs=

	pushd tools/perf

	use demangle || makeargs="${makeargs} NO_DEMANGLE= "

	emake ${makeargs} \
		CC="$(tc-getCC)" AR="$(tc-getAR)" \
		prefix="/usr" bindir_relative="sbin" \
		CFLAGS="${CFLAGS}" \
		LDFLAGS="${LDFLAGS}" || die

	if use doc; then
		pushd Documentation
		emake ${makeargs} || die
		popd
	fi

	popd
}

src_install() {
	pushd tools/perf

	# Don't use make install or it'll be re-building the stuff :(
	dosbin perf || die

	dodoc CREDITS || die

	if use doc; then
		dodoc Documentation/*.txt || die
		dohtml Documentation/*.html || die
		doman Documentation/*.1 || die
	fi

	popd
}
