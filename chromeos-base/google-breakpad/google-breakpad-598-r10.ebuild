# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="37e7cc53471144c95ed1a71f82c63561c2f55b25"

inherit cros-debug cros-workon toolchain-funcs

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
	if tc-is-cross-compiler; then
		pushd "${S}"/src/tools/linux/dump_syms
		epatch "${FILESDIR}"/dump_syms_mk.diff || die "Unable to patch"
		popd
	else
		elog "Using host compiler and leaving -m32 to build dump_syms"
	fi
}

src_configure() {
	tc-export CC CXX LD PKG_CONFIG
	# We purposefully disable optimizations due to optimizations causing
	# src/processor code to crash (minidump_stackwalk) as well as tests
	# to fail.  See
	# http://code.google.com/p/google-breakpad/issues/detail?id=400.
	CFLAGS="${CFLAGS} -O0" CXXFLAGS="${CXXFLAGS} -O0" econf || \
		die "configure failed"
}

src_compile() {
	tc-export CC CXX PKG_CONFIG
	emake -C src/tools/linux/core2md || die "core2md emake failed"
	rm src/common/linux/file_id.o
	emake -C src/tools/linux/dump_syms || die "dumpsyms emake failed"
	emake clean || die "make clean failed"
	emake || die "emake failed"
	emake -C src/tools/linux/symupload || die "symupload emake failed"
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
