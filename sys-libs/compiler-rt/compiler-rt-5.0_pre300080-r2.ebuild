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
DEPEND="sys-devel/llvm"
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
		EGIT_COMMIT="9b8267f708fe852f22a50a3f8f5ff21f9c7f318f" #r301387
	else
		EGIT_COMMIT="059c103b581e37d2be47cb403769bff20808bca2" #r300080
	fi
	git-2_src_unpack
}

src_prepare() {
	# Cherry-picks
	CHERRIES=""
	if  ! use llvm-next ; then
		# No llvm-next cherry-picks right now.
		CHERRIES+=" 385d9f6d5abb6b2d4ea27e59ac1e7b0e20d54f7c " # r300531
		CHERRIES+=" 46a48e5918ab64e40ed8b929fdb8d2ff4117cfa1 " # r301243
	fi
	for cherry in ${CHERRIES}; do
		epatch "${FILESDIR}/cherry/${cherry}.patch"
	done

	# Apply patches
	if use llvm-next; then
	# leak-whitelist patch does not cleanly apply to llvm-next.
		epatch "${FILESDIR}"/llvm-next-leak-whitelist.patch
	else
		epatch "${FILESDIR}"/llvm-4.0-leak-whitelist.patch
	fi
	epatch "${FILESDIR}"/clang-4.0-asan-default-path.patch
}

src_configure() {
	export CC="${CTARGET}-gcc ${LDFLAGS}"
	export CXX="${CTARGET}-g++ ${LDFLAGS}"
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
