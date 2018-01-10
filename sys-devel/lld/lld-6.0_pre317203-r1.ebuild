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
	EGIT_COMMIT="dc4c49229f1371f873e16cc960ff5767acfa881e" #r317082

	if use llvm-next && has_version --host-root 'sys-devel/llvm[llvm-next]'; then
		EGIT_COMMIT="901304abaacc60ef78ab5983d24f0f4666a70fe1" #r321473
	fi

	git-r3_fetch
	git-r3_checkout
}

src_prepare() {
	if use llvm-next  && has_version --host-root 'sys-devel/llvm[llvm-next]'; then
		epatch "${FILESDIR}/$PN-invoke-name-llvm-next.patch"
		pick_next_cherries
	else
		epatch "${FILESDIR}/$PN-invoke-name.patch"
		pick_cherries
	fi
}
src_configure() {
	local mycmakeargs=(
		#-DBUILD_SHARED_LIBS=ON
		# TODO: fix detecting pthread upstream in stand-alone build
		-DPTHREAD_LIB='-lpthread'
	)
	cmake-utils_src_configure
}
