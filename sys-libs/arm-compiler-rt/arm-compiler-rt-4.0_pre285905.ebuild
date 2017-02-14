# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit cros-constants cmake-utils git-2

EGIT_REPO_URI=${CROS_GIT_HOST_URL}/chromiumos/third_party/compiler-rt.git
DESCRIPTION="Compiler-rt for ARM"
HOMEPAGE="http://compiler-rt.llvm.org/"

LICENSE="UoI-NCSA"
SLOT="0"
KEYWORDS="*"
IUSE=""

EGIT_COMMIT=692b01cdac57043f8a69f5943142266a63cb721d
DEPEND="cross-armv7a-cros-linux-gnueabi/gcc
		~sys-devel/llvm-${PV}"

src_unpack() {
	git-2_src_unpack
}

src_configure() {
	export CC=armv7a-cros-linux-gnueabi-gcc
	export CXX=armv7a-cros-linux-gnueabi-g++
	export STRIP=armv7a-cros-linux-gnueabi-strip
	export OBJCOPY=armv7a-cros-linux-gnueabi-objcopy
	append-flags -fomit-frame-pointer -mfpu=neon
	BUILD_DIR=${WORKDIR}/${P}_build
	local libdir=$(get_libdir)
	local llvm_version=$(llvm-config --version)
	# Strip svn from llvm_version string
	local clang_version=${llvm_version%svn}
	local mycmakeargs=(
			"${mycmakeargs[@]}"
			-DCOMPILER_RT_TEST_TARGET_TRIPLE="armv7a-cros-linux-gnueabi"
			-DCOMPILER_RT_INSTALL_PATH="${EPREFIX}/usr/${libdir}/clang/${clang_version}"
			-DCOMPILER_RT_OUTPUT_DIR="${BUILD_DIR}/${libdir}/clang/${clang_version}"
	)
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	# includes are mistakenly installed for all sanitizers and xray
	# These files conflict with files provided in llvm ebuild
	rm -rf "${ED}"usr/$(get_libdir)/clang/*/include || die
	rm -f "${ED}"usr/$(get_libdir)/clang/*/asan_blacklist.txt || die
}
