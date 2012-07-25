# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/perf/perf-2.6.32.ebuild,v 1.1 2009/12/04 16:33:24 flameeyes Exp $
CROS_WORKON_COMMIT="2cf226b650be7ea6d8d94e3bcebfe345a7c7ca85"
CROS_WORKON_TREE="f8863ae0cd510f52be4f71530d9704c211d26099"

EAPI=4
CROS_WORKON_PROJECT="chromiumos/third_party/kernel"

inherit cros-workon eutils toolchain-funcs linux-info

DESCRIPTION="Userland tools for Linux Performance Counters"
HOMEPAGE="http://perf.wiki.kernel.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="+demangle +doc perl python ncurses"

RDEPEND="demangle? ( sys-devel/binutils )
	dev-libs/elfutils
	ncurses? ( dev-libs/newt )
	perl? ( || ( >=dev-lang/perl-5.10 sys-devel/libperl ) )
	!dev-util/perf-next"
DEPEND="${RDEPEND}
	doc? ( app-text/asciidoc app-text/xmlto )"

CROS_WORKON_LOCALNAME="kernel/files"

src_compile() {
	local makeargs=

	pushd tools/perf

	use demangle || makeargs="${makeargs} NO_DEMANGLE=1 "
	use perl || makeargs="${makeargs} NO_LIBPERL=1 "
	use python || makeargs="${makeargs} NO_LIBPYTHON=1 "
	use ncurses || makeargs="${makeargs} NO_NEWT=1 "

	if use arm; then
		export ARM_SHA=1
	fi

	emake ${makeargs} \
		CC="$(tc-getCC)" AR="$(tc-getAR)" \
		prefix="/usr" bindir_relative="sbin" \
		CFLAGS="${CFLAGS}" \
		LDFLAGS="${LDFLAGS}"

	if use doc; then
		pushd Documentation
		emake ${makeargs}
		popd
	fi

	popd
}

src_install() {
	pushd tools/perf

	dosbin perf
	dosbin perf-archive

	dodoc CREDITS

	if use doc; then
		dodoc Documentation/*.txt
		dohtml Documentation/*.html
		doman Documentation/*.1
	fi

	popd
}
