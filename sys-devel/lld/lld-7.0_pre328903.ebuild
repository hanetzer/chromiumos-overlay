# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

: ${CMAKE_MAKEFILE_GENERATOR:=ninja}
CMAKE_MIN_VERSION=3.7.0-r1
PYTHON_COMPAT=( python2_7 )

inherit cros-constants cmake-utils git-r3 llvm python-any-r1 toolchain-funcs

DESCRIPTION="The LLVM linker (link editor)"
HOMEPAGE="https://llvm.org/"
SRC_URI=""
EGIT_REPO_URI="${CROS_GIT_HOST_URL}/external/llvm.org/lld
	https://git.llvm.org/git/lld.git"

LICENSE="UoI-NCSA"
SLOT="0"
KEYWORDS="*"
IUSE="llvm-next"
RDEPEND="sys-devel/llvm"
DEPEND="${RDEPEND}"

pick_cherries() {
	CHERRIES=""
	pushd "${S}" >/dev/null || die
	for cherry in ${CHERRIES}; do
		epatch "${FILESDIR}/cherry/${cherry}.patch"
	done
	popd >/dev/null || die
}

pick_next_cherries() {
	CHERRIES=""
	pushd "${S}" >/dev/null || die
	for cherry in ${CHERRIES}; do
		epatch "${FILESDIR}/cherry/${cherry}.patch"
	done
	popd >/dev/null || die
}

python_check_deps() {
	has_version "dev-python/lit[${PYTHON_USEDEP}]"
}

pkg_setup() {
	llvm_pkg_setup
}

src_unpack() {
	EGIT_COMMIT="500a98301c1b0fec54bed5062c83375e3f13a18d" #r328902

	if use llvm-next && has_version --host-root 'sys-devel/llvm[llvm-next]'; then
		EGIT_COMMIT="500a98301c1b0fec54bed5062c83375e3f13a18d" #r328902
	fi

	git-r3_fetch
	git-r3_checkout
}

src_prepare() {
	if use llvm-next  && has_version --host-root 'sys-devel/llvm[llvm-next]'; then
		pick_next_cherries
	else
		pick_cherries
	fi
	epatch "${FILESDIR}/$PN-invoke-name.patch"
}
src_configure() {
	# HACK: This is a temporary hack to detect the c++ library used in libLLVM.so
	# lld needs to link with same library as llvm but there is no good way to find
	# that. So grep the libc++ usage and if not used link with libstdc++.
	# Remove this hack once everything is migrated to libc++.
	# https://crbug.com/801681
	if tc-is-clang; then
		if [[ -n $(scanelf -qN libc++.so.1 /usr/$(get_libdir)/libLLVM.so) ]]; then
			append-flags -stdlib=libc++
			append-ldflags -stdlib=libc++
		else
			append-flags -stdlib=libstdc++
			append-ldflags -stdlib=libstdc++
		fi
	fi
	# End HACK
	local mycmakeargs=(
		#-DBUILD_SHARED_LIBS=ON
		# TODO: fix detecting pthread upstream in stand-alone build
		-DPTHREAD_LIB='-lpthread'
	)
	cmake-utils_src_configure
}
