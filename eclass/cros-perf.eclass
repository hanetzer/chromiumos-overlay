# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

[[ ${EAPI} != "4" ]] && die "Only EAPI=4 is supported"

inherit cros-workon eutils toolchain-funcs linux-info

DESCRIPTION="Userland tools for Linux Performance Counters"
HOMEPAGE="http://perf.wiki.kernel.org/"
LICENSE="GPL-2"

SLOT="0"
IUSE="-asan -clang +demangle +doc perl python ncurses"
REQUIRED_USE="asan? ( clang )"

RDEPEND="demangle? ( sys-devel/binutils )
	dev-libs/elfutils
	ncurses? ( dev-libs/newt )
	perl? ( || ( >=dev-lang/perl-5.10 sys-devel/libperl ) )"
DEPEND="${RDEPEND}
	doc? ( app-text/asciidoc app-text/xmlto )"

src_configure() {
	clang-setup-env
	cros-workon_src_configure
}

src_compile() {
	local makeargs=
	local kernel_arch=${CHROMEOS_KERNEL_ARCH:-$(tc-arch-kernel)}

	pushd tools/perf

	use demangle || makeargs="${makeargs} NO_DEMANGLE=1 "
	use perl || makeargs="${makeargs} NO_LIBPERL=1 "
	use python || makeargs="${makeargs} NO_LIBPYTHON=1 "
	use ncurses || makeargs="${makeargs} NO_NEWT=1 "

	if use arm; then
		export ARM_SHA=1
	fi

	emake ${makeargs} \
		ARCH=${kernel_arch} \
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
