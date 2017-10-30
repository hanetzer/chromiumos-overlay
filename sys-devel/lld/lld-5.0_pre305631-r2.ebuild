# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

: ${CMAKE_MAKEFILE_GENERATOR:=ninja}
CMAKE_MIN_VERSION=3.7.0-r1
PYTHON_COMPAT=( python2_7 )

inherit cros-constants cmake-utils git-r3 llvm python-any-r1

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

python_check_deps() {
	has_version "dev-python/lit[${PYTHON_USEDEP}]"
}

pkg_setup() {
	llvm_pkg_setup
}

src_unpack() {
	EGIT_COMMIT="b0147d1baf5593dcae1b25f4f6ee565bc5d3f438"
	if use llvm-next; then
		EGIT_COMMIT="c9e633dcb3997ab998bcedcf11d4e36d5af44a6c" #316180
	fi
	git-r3_fetch
	git-r3_checkout
}

src_configure() {
	local mycmakeargs=(
		#-DBUILD_SHARED_LIBS=ON
		# TODO: fix detecting pthread upstream in stand-alone build
		-DPTHREAD_LIB='-lpthread'
	)
	cmake-utils_src_configure
}
