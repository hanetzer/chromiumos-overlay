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
		# llvm:r328903 https://critique.corp.google.com/#review/191960518
		EGIT_COMMIT="13c69d3bcd85a38da14fd28322b0b2f8b675d943" #r328849
	else
		# llvm:r326829 https://critique.corp.google.com/#review/188273767
		EGIT_COMMIT="6a52b697d564699d511de92bce88e15bf6fc56b8" #r326768
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
	if [[ ${CTARGET} == armv7a* ]]; then
		# Use vfpv3 to be able to target non-neon targets
		append-flags -mfpu=vfpv3
	elif [[ ${CTARGET} == armv7m* ]]; then
		# Some of the arm32 assembly builtins in compiler-rt need vfpv2.
		# Passing this flag should not be required but currently
		# upstream compiler-rt's cmake config does not provide a way to
		# exclude these asm files.
		append-flags -Wa,-mfpu=vfpv2
	fi
	BUILD_DIR=${WORKDIR}/${P}_build
	local llvm_version=$(llvm-config --version)
	# Strip git and svn from llvm_version string
	local clang_version=${llvm_version%svn*}
	clang_version=${clang_version%git*}
	local libdir=$(llvm-config --libdir)

	local mycmakeargs=()
	if [[ ${CTARGET} == *-eabi ]]; then
		mycmakeargs+=(
			-DCMAKE_TRY_COMPILE_TARGET_TYPE=STATIC_LIBRARY
			-DCOMPILER_RT_OS_DIR=baremetal
			-DCOMPILER_RT_BAREMETAL_BUILD=yes
			-DCMAKE_C_COMPILER_TARGET="${CTARGET}"
			-DCOMPILER_RT_DEFAULT_TARGET_ONLY=yes
		)
	else
		mycmakeargs+=(
			-DCOMPILER_RT_TEST_TARGET_TRIPLE="${CTARGET}"
		)
	fi
	mycmakeargs+=(
		-DCOMPILER_RT_INSTALL_PATH="${EPREFIX}${libdir}/clang/${clang_version}"
	)
	cmake-utils_src_configure
}

src_install() {
	# There is install conflict between cross-armv7a-cros-linux-gnueabihf
	# and cross-armv7a-cros-linux-gnueabi. Remove this once we are ready to
	# move to cross-armv7a-cros-linux-gnueabihf.
	if [[ ${CTARGET} == armv7a-cros-linux-gnueabihf ]] ; then
		return
	fi
	cmake-utils_src_install

	# includes and docs are installed for all sanitizers and xray
	# These files conflict with files provided in llvm ebuild
	local libdir=$(llvm-config --libdir)
	rm -rf "${ED}"usr/share || die
	rm -rf "${ED}"${libdir}/clang/*/include || die
	rm -f "${ED}"${libdir}/clang/*/*_blacklist.txt || die
	rm -f "${ED}"${libdir}/clang/*/*/*_blacklist.txt || die
	rm -f "${ED}"${libdir}/clang/*/dfsan_abilist.txt || die
	rm -f "${ED}"${libdir}/clang/*/*/dfsan_abilist.txt || die

	# This section can be removed once prebuilds for 326829 have been created.
	local llvm_version=$(llvm-config --version)
	local clang_version=${llvm_version%svn*}
	clang_version=${clang_version%git*}
	if [[ ${clang_version} == "6.0.0" ]] ; then
		new_version="7.0.0"
	else
		new_version="6.0.0"
	fi
	cp -r  "${D}${libdir}/clang/${clang_version}" "${D}${libdir}/clang/${new_version}"
}
