# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT=894236585f9b631a3994214143cfb9a559c12691
CROS_WORKON_TREE="47b703ec01875ba3e77bd97ce5c039c656758f61"

EAPI=2
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
	if ! tc-is-cross-compiler; then
		einfo "Creating a separate 32b src directory"
		mkdir ../work32
		cp -a . ../work32
		mv ../work32 .
	fi
}

src_configure() {
	#TODO(raymes): Uprev breakpad so this isn't necessary. See
	# (crosbug.com/14275).
	[ "$ARCH" = "arm" ] && append-cflags "-marm" && append-cxxflags "-marm"

	# We purposefully disable optimizations due to optimizations causing
	# src/processor code to crash (minidump_stackwalk) as well as tests
	# to fail.  See
	# http://code.google.com/p/google-breakpad/issues/detail?id=400.
	append-flags "-O0"

	tc-export CC CXX LD PKG_CONFIG

	if tc-is-cross-compiler; then
		econf --disable-md2core || die "configure failed"
	else
		econf || die "configure failed"
	        einfo "Running 32b configuration"
		cd work32 || die "chdir failed"
		append-flags "-m32"
		econf --disable-md2core || die "configure failed"
		filter-flags "-m32"
	fi
}

src_compile() {
	tc-export CC CXX PKG_CONFIG
	emake || die "emake failed"

	if ! tc-is-cross-compiler; then
		cd work32 || die "chdir failed"
		einfo "Building dump_syms with -m32"
		emake src/tools/linux/dump_syms/dump_syms || die "emake failed"
	fi
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
	dobin src/tools/linux/core2md/core2md \
	      src/tools/linux/dump_syms/dump_syms \
	      src/tools/linux/symupload/sym_upload \
	      src/tools/linux/symupload/minidump_upload || die
	if ! tc-is-cross-compiler; then
		newbin work32/src/tools/linux/dump_syms/dump_syms dump_syms.32
		dobin src/tools/linux/md2core/minidump-2-core
	fi
}
