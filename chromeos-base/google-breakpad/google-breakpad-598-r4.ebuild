# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit eutils subversion toolchain-funcs

DESCRIPTION="Google crash reporting"
HOMEPAGE="http://code.google.com/p/google-breakpad"
SRC_URI=""
ESVN_REPO_URI="http://google-breakpad.googlecode.com/svn/trunk@${PV}"
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE=""

RDEPEND="net-misc/curl"
DEPEND="${RDEPEND}"

src_prepare() {
	pushd "${S}"/src/tools/linux/symupload
	epatch "${FILESDIR}"/sym_upload.diff || die "Unable to patch"
	epatch "${FILESDIR}"/sym_upload_mk.diff || die "Unable to patch"
	epatch "${FILESDIR}"/minidump_upload.diff || die "Unable to patch"
	popd
	if tc-is-cross-compiler; then
		pushd "${S}"/src/tools/linux/dump_syms
		epatch "${FILESDIR}"/dump_syms_mk.diff || die "Unable to patch"
		popd
	else
	    elog "Using host compiler and leaving -m32 to build dump_syms"
	fi
	pushd "${S}"
	epatch "${FILESDIR}"/splitdebug.diff || die "Unable to patch splitdebug"
	popd
	cp -Rv "${FILESDIR}"/core2md/* "${S}/src" || \
	    die "Unable to overlay files"
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
