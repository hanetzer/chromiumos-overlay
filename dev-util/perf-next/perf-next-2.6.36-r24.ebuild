# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/perf/perf-2.6.32.ebuild,v 1.1 2009/12/04 16:33:24 flameeyes Exp $

EAPI=2
CROS_WORKON_COMMIT="98054dd312b9be6651d76b1ceac19989bf706c07"

inherit cros-workon eutils toolchain-funcs linux-info

DESCRIPTION="Userland tools for Linux Performance Counters"
HOMEPAGE="http://perf.wiki.kernel.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE="+demangle +doc"

RDEPEND="demangle? ( sys-devel/binutils )
	dev-libs/elfutils"
DEPEND="${RDEPEND}
	doc? ( app-text/asciidoc app-text/xmlto )"

CROS_WORKON_PROJECT="kernel-next"
CROS_WORKON_LOCALNAME="kernel-next"

src_compile() {
	local makeargs=

	pushd tools/perf

	use demangle || makeargs="${makeargs} NO_DEMANGLE= "

	if use arm; then
		export ARM_SHA=1
	fi

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
