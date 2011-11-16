# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="223e62f415afad32924481543787f4349afd281d"
CROS_WORKON_PROJECT="chromiumos/platform/google-breakpad"

inherit autotools cros-debug cros-workon toolchain-funcs

DESCRIPTION="Google crash reporting"
HOMEPAGE="http://code.google.com/p/google-breakpad"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE=""

RDEPEND="net-misc/curl"
DEPEND="${RDEPEND}"

src_prepare() {
        eautoreconf || die "eautoreconf failed"
}

src_configure() {
	#TODO(raymes): Uprev breakpad so this isn't necessary. See
	# (crosbug.com/14275).
	[ "$ARCH" = "arm" ] && append-cflags "-marm" && append-cxxflags "-marm"

	# We purposefully disable optimizations due to optimizations causing
	# src/processor code to crash (minidump_stackwalk) as well as tests
	# to fail.  See
	# http://code.google.com/p/google-breakpad/issues/detail?id=400.
	append-cflags "-O0"
	append-cxxflags "-O0"

	if ! tc-is-cross-compiler; then
		einfo "Building local stuff with -m32"
		append-flags "-m32"
	fi
	tc-export CC CXX LD PKG_CONFIG
	econf --disable-md2core || die "configure failed"
}

src_compile() {
	tc-export CC CXX PKG_CONFIG
	emake -C src/tools/linux/core2md || die "core2md emake failed"
	rm src/common/linux/file_id.o
	emake || die "emake failed"
}

src_test() {
	emake check || die "Tests failed"
}

src_install() {
	tc-export CXX PKG_CONFIG
	emake DESTDIR="${D}" install || die "emake install failed"
	insinto /usr/include/google-breakpad/client/linux/handler
	doins src/client/linux/handler/*.h || die
	insinto /usr/include/google-breakpad/client/linux/crash_generation
	doins src/client/linux/crash_generation/*.h || die
	insinto /usr/include/google-breakpad/common/linux
	doins src/common/linux/*.h || die
	insinto /usr/include/google-breakpad/processor
	doins src/processor/*.h || die
	dobin src/tools/linux/core2md/core_dumper \
	      src/tools/linux/core2md/core2md \
	      src/tools/linux/dump_syms/dump_syms \
	      src/tools/linux/symupload/sym_upload \
	      src/tools/linux/symupload/minidump_upload || die
}
