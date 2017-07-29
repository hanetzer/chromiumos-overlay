# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit cros-constants cmake-utils git-2 cros-llvm

DESCRIPTION="C++ runtime stack unwinder from LLVM"
HOMEPAGE="https://github.com/llvm-mirror/libunwind"
SRC_URI=""
EGIT_REPO_URI="${CROS_GIT_HOST_URL}/external/llvm.org/libunwind"

LICENSE="|| ( UoI-NCSA MIT )"
SLOT="0"
KEYWORDS="*"
IUSE="debug llvm-next +static-libs +shared-libs"
RDEPEND="!${CATEGORY}/libunwind"

src_unpack() {
	if use llvm-next; then
		EGIT_COMMIT="86219d8c6a73f95e694b4e1594e1a8a0a33613b6" #r303206
	else
		EGIT_COMMIT="ab68429b2d2159947e1c96933a034afbfb1feb55" #r300020
	fi
	git-2_src_unpack
}

src_configure() {
	# Setup llvm toolchain for cross-compilation
	setup_cross_toolchain

	# Add neon fpu for armv7a
	if [[ ${CATEGORY} == cross-armv7a* ]] ; then
		append-flags -mfpu=neon
	fi
	local libdir=$(get_libdir)
	local mycmakeargs=(
		"${mycmakeargs[@]}"
		-DLLVM_LIBDIR_SUFFIX=${libdir#lib}
		-DLIBUNWIND_ENABLE_ASSERTIONS=$(usex debug)
		-DLIBUNWIND_ENABLE_STATIC=$(usex static-libs)
		-DLIBUNWIND_ENABLE_SHARED=$(usex shared-libs)
		-DLIBUNWIND_TARGET_TRIPLE=${CTARGET}
	)

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
	# install headers like sys-libs/libunwind
	insinto "${PREFIX}"/include
	doins -r include/.
}
