# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit eutils toolchain-funcs

DESCRIPTION="Google crash reporting"
HOMEPAGE="http://code.google.com/p/google-breakpad"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE=""

RDEPEND="net-misc/curl"
DEPEND="${RDEPEND}"

src_unpack() {
        local third_party="${CHROMEOS_ROOT}/src/third_party"
        elog "Using third_party: $third_party"
        mkdir -p "${S}"
        cp -a "${third_party}"/google-breakpad/files/* "${S}" || die
}

src_prepare() {
        pushd "${S}"/src/tools/linux/symupload
        epatch "${FILESDIR}"/sym_upload.diff || die "Unable to patch"
	epatch "${FILESDIR}"/sym_upload_mk.diff || die "Unable to patch"
	epatch "${FILESDIR}"/minidump_upload.diff || die "Unable to patch"
        popd
        pushd "${S}"/src/tools/linux/dump_syms
        epatch "${FILESDIR}"/dump_syms_mk.diff || die "Unable to patch"
        popd
}

src_compile() {
	tc-export CC CXX PKG_CONFIG
	emake || die "emake failed"
        pushd src/tools/linux/dump_syms
	emake || die "dumpsyms emake failed"
	popd
        pushd src/tools/linux/symupload
	emake || die "symupload emake failed"
	popd
}

src_install() {
	tc-export CXX PKG_CONFIG
	emake DESTDIR="${D}" install || die "emake install failed"
	insinto /usr/include/google-breakpad/client/linux/handler
	doins "${S}"/src/client/linux/handler/*.h || die
	insinto /usr/include/google-breakpad/client/linux/crash_generation
	doins "${S}"/src/client/linux/crash_generation/*.h || die
	insinto /usr/include/google-breakpad/common/linux
	doins "${S}"/src/common/linux/*.h || die
	insinto /usr/include/google-breakpad/processor
	doins "${S}"/src/processor/*.h || die
	into /usr
	dobin "${S}"/src/tools/linux/dump_syms/dump_syms \
	      "${S}"/src/tools/linux/symupload/sym_upload \
	      "${S}"/src/tools/linux/symupload/minidump_upload || die
}
