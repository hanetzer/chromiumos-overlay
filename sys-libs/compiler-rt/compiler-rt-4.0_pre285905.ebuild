# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils toolchain-funcs cros-constants cmake-utils git-2

EGIT_REPO_URI=${CROS_GIT_HOST_URL}/chromiumos/third_party/compiler-rt.git
DESCRIPTION="Compiler runtime library for clang"
HOMEPAGE="http://compiler-rt.llvm.org/"

LICENSE="UoI-NCSA"
SLOT="0"
KEYWORDS="*"
IUSE="llvm-next"
DEPEND="~sys-devel/llvm-${PV}"
if [[ ${CATEGORY} == cross-* ]] ; then
	DEPEND+="
		${CATEGORY}/binutils
		${CATEGORY}/gcc
		"
fi

export CBUILD=${CBUILD:-${CHOST}}
export CTARGET=${CTARGET:-${CHOST}}
if [[ ${CTARGET} == ${CHOST} ]] ; then
	if [[ ${CATEGORY} == cross-* ]] ; then
		export CTARGET=${CATEGORY#cross-}
	fi
fi

src_unpack() {
	if use llvm-next; then
		EGIT_COMMIT="059c103b581e37d2be47cb403769bff20808bca2" #r300080
	else
		EGIT_COMMIT="692b01cdac57043f8a69f5943142266a63cb721d" #r285821
	fi
	git-2_src_unpack
}

src_configure() {
	export CC="$(tc-getCC ${CTARGET}) ${LDFLAGS}"
	export CXX="$(tc-getCXX ${CTARGET}) ${LDFLAGS}"
	export STRIP="$(tc-getSTRIP ${CTARGET})"
	export OBJCOPY="$(tc-getOBJCOPY ${CTARGET})"
	append-flags -fomit-frame-pointer
	if [[ ${CATEGORY} == cross-armv7a* ]] ; then
		append-flags -mfpu=neon
	fi
	BUILD_DIR=${WORKDIR}/${P}_build
	local libdir=$(get_libdir)
	local llvm_version=$(llvm-config --version)
	# Strip svn from llvm_version string
	local clang_version=${llvm_version%svn}
	local mycmakeargs=(
			"${mycmakeargs[@]}"
			-DCOMPILER_RT_TEST_TARGET_TRIPLE="${CTARGET}"
			-DCOMPILER_RT_INSTALL_PATH="${EPREFIX}/usr/${libdir}/clang/${clang_version}"
			-DCOMPILER_RT_OUTPUT_DIR="${BUILD_DIR}/${libdir}/clang/${clang_version}"
	)
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	# includes and docs are installed for all sanitizers and xray
	# These files conflict with files provided in llvm ebuild
	rm -rf "${ED}"usr/share || die
	rm -rf "${ED}"usr/$(get_libdir)/clang/*/include || die
	rm -f "${ED}"usr/$(get_libdir)/clang/*/asan_blacklist.txt || die
	rm -f "${ED}"usr/$(get_libdir)/clang/*/msan_blacklist.txt || die
	rm -f "${ED}"usr/$(get_libdir)/clang/*/dfsan_abilist.txt || die
	rm -f "${ED}"usr/$(get_libdir)/clang/*/dfsan_blacklist.txt || die
}
