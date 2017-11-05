# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils toolchain-funcs cros-constants cmake-utils git-2 cros-llvm

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

src_unpack() {
	# For this version of the ebuild, llvm and llvm-next are the same until we roll
	# a new version of llvm-next.
	if use llvm-next; then
		# llvm:r316199 https://critique.corp.google.com/#review/17310468
		EGIT_COMMIT="98adaa2097783c0fe3a4c948397e3f2182dcc5d2" #r316048
	else
		# llvm:r316199 https://critique.corp.google.com/#review/17310468
		EGIT_COMMIT="98adaa2097783c0fe3a4c948397e3f2182dcc5d2" #r316048
	fi
	git-2_src_unpack
}

src_prepare() {
	# Cherry-picks
	local CHERRIES=""
	if use llvm-next; then
		CHERRIES+=""
	else
		CHERRIES+=""
	fi
	for cherry in ${CHERRIES}; do
		epatch "${FILESDIR}/cherry/${cherry}.patch"
	done

	# Apply patches
	epatch "${FILESDIR}"/llvm-next-leak-whitelist.patch
	epatch "${FILESDIR}"/clang-4.0-asan-default-path.patch
}

src_configure() {
	setup_cross_toolchain
	# Need libgcc for bootstrapping.
	append-flags "-rtlib=libgcc"
	# Compiler-rt libraries need to be built before libc++ when
	# libc++ is default in clang.
	# Compiler-rt builtins are C only.
	# Even though building compiler-rt libraries does not require C++ compiler,
	# CMake does not like a non-working C++ compiler.
	# Avoid CMake complains about non-working C++ compiler
	# by using libstdc++ since libc++ is built after compiler-rt in crossdev.
	append-cxxflags "-stdlib=libstdc++"
	append-flags "-fomit-frame-pointer"
	if [[ ${CATEGORY} == cross-armv7a* ]] ; then
		# Use vfpv3 to be able to target non-neon targets
		append-flags -mfpu=vfpv3
	fi
	BUILD_DIR=${WORKDIR}/${P}_build
	local llvm_version=$(llvm-config --version)
	# Strip git and svn from llvm_version string
	local clang_version=${llvm_version%svn*}
	clang_version=${clang_version%git*}
	local libdir=$(llvm-config --libdir)
	local mycmakeargs=(
			"${mycmakeargs[@]}"
			-DCOMPILER_RT_TEST_TARGET_TRIPLE="${CTARGET}"
			-DCOMPILER_RT_INSTALL_PATH="${EPREFIX}${libdir}/clang/${clang_version}"
	)
	cmake-utils_src_configure
}

src_install() {
	# There is install conflict between cross-armv7a-cros-linux-gnueabihf
	# and cross-armv7a-cros-linux-gnueabi. Remove this once we are ready to
	# move to cross-armv7a-cros-linux-gnueabihf.
	if [[ ${CATEGORY} == cross-armv7a-cros-linux-gnueabihf ]] ; then
		return
	fi
	cmake-utils_src_install

	# includes and docs are installed for all sanitizers and xray
	# These files conflict with files provided in llvm ebuild
	local libdir=$(llvm-config --libdir)
	rm -rf "${ED}"usr/share || die
	rm -rf "${ED}"${libdir}/clang/*/include || die
	rm -f "${ED}"${libdir}/clang/*/*_blacklist.txt || die
	rm -f "${ED}"${libdir}/clang/*/dfsan_abilist.txt || die

	# This section can be removed once prebuilds for 316199 have been created. 
	local llvm_version=$(llvm-config --version)
	local clang_version=${llvm_version%svn*}
	clang_version=${clang_version%git*}
	if [[ ${clang_version} == "5.0.0" ]] ; then
		new_version="6.0.0"
	else
		new_version="5.0.0"
	fi
	#

	cp -r  "${D}${libdir}/clang/${clang_version}" "${D}${libdir}/clang/${new_version}"
}
