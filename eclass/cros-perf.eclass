# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

[[ ${EAPI} != "4" ]] && die "Only EAPI=4 is supported"

CROS_WORKON_OUTOFTREE_BUILD=1

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
	mkdir -p "$(cros-workon_get_build_dir)"
	# The version script likes to try & grab locks in here.
	addpredict "${S}"/.git

	clang-setup-env
	cros-workon_src_configure
}

src_compile() {
	local makeargs=(
		O="$(cros-workon_get_build_dir)"
		ARCH="${CHROMEOS_KERNEL_ARCH:-$(tc-arch-kernel)}"
		CC="$(tc-getCC)"
		AR="$(tc-getAR)"
		prefix="/usr"
		bindir_relative="sbin"
		CFLAGS="${CFLAGS} ${CPPFLAGS}"
		LDFLAGS="${LDFLAGS}"
	)

	use demangle || makeargs+=( NO_DEMANGLE=1 )
	use perl || makeargs+=( NO_LIBPERL=1 )
	use python || makeargs+=( NO_LIBPYTHON=1 )
	use ncurses || makeargs+=( NO_NEWT=1 )

	emake -C tools/perf "${makeargs[@]}"
	use doc && emake -C tools/perf/Documentation "${makeargs[@]}"
}

src_install() {
	cd tools/perf
	dodoc CREDITS

	cd "$(cros-workon_get_build_dir)"
	dosbin perf{,-archive}

	if use doc; then
		dodoc *.txt
		dohtml *.html
		doman *.1
	fi
}
