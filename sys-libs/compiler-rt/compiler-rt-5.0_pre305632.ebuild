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
		EGIT_COMMIT="f0d7258f4a2f5e6443011f7be011b5e9999c33f2" #r305593
	else
		EGIT_COMMIT="f0d7258f4a2f5e6443011f7be011b5e9999c33f2" #r305593
	fi
	git-2_src_unpack
}

src_prepare() {
	# Cherry-picks
	CHERRIES=""
	for cherry in ${CHERRIES}; do
		epatch "${FILESDIR}/cherry/${cherry}.patch"
	done

	# Apply patches
	epatch "${FILESDIR}"/llvm-next-leak-whitelist.patch
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
