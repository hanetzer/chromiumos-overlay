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
		EGIT_COMMIT="671ef704cfa72856adc7c9a3686a21cb3c1c00ab" #r307448
	else
		EGIT_COMMIT="059c103b581e37d2be47cb403769bff20808bca2" #r300080
	fi
	git-2_src_unpack
}

src_prepare() {
	# Cherry-picks
	CHERRIES=""
	if use llvm-next ; then
		CHERRIES=""
	else
		CHERRIES+=" 385d9f6d5abb6b2d4ea27e59ac1e7b0e20d54f7c " # r300531
		CHERRIES+=" 46a48e5918ab64e40ed8b929fdb8d2ff4117cfa1 " # r301243
		CHERRIES+=" 96eed06b6e57a3c8e2593e73d6f33bdd407f43b9 " # r303112
		CHERRIES+=" 99e2e66daf8d334858cec4f6e8e7a39d6a535a55 " # r303188
		CHERRIES+=" c74078b0a058c70de3504cb2533352ee48e71836 " # r303190
		CHERRIES+=" e60a00c0dfb05bad4912315912b70fa35050a058 " # r303195
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
		# Use vfpv3 to be able to target non-neon targets
		append-flags -mfpu=vfpv3
	fi
	BUILD_DIR=${WORKDIR}/${P}_build
	local libdir=$(get_libdir)
	local llvm_version=$(llvm-config --version)
	# Strip git and svn from llvm_version string
	local clang_version=${llvm_version%svn*}
	clang_version=${clang_version%git*}
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
