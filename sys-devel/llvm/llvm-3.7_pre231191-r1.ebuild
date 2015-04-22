# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/llvm/llvm-3.6.0.ebuild,v 1.1 2015/02/28 09:38:22 voyageur Exp $

EAPI=5

PYTHON_COMPAT=( python2_7 pypy )

inherit cros-constants cmake-utils eutils flag-o-matic git-2 git-r3 multibuild multilib \
	multilib-minimal python-r1 toolchain-funcs pax-utils check-reqs prefix

DESCRIPTION="Low Level Virtual Machine"
HOMEPAGE="http://llvm.org/"

EGIT_REPO_URIS=(
        "llvm"
                ""
                "git://github.com/llvm-mirror/llvm.git"
                #"http://llvm.org/git/llvm.git"
                #"${CROS_GIT_HOST_URL}/chromiumos/third_party/llvm.git"
                "1df6d33c5eb998cc38707bb9a97f3fa6cbf0ca53" # EGIT_COMMIT
        "compiler-rt"
                "projects/compiler-rt"
                #"git://github.com/llvm-mirror/compiler-rt.git"
                #"http://llvm.org/git/compiler-rt.git"
                "${CROS_GIT_HOST_URL}/chromiumos/third_party/compiler-rt.git"
                "70b3c4464a4067db2cd9862736611fdf6739f451" # EGIT_COMMIT
        "clang"
                "tools/clang"
                #"git://github.com/llvm-mirror/clang.git"
                #"http://llvm.org/git/clang.git"
                "${CROS_GIT_HOST_URL}/chromiumos/third_party/clang.git"
                "6b7e300a9c14a2ff364d8ef8a0f7510378f38dbc"  # EGIT_COMMIT
	"clang-tools-extra"
		"tools/clang/tools/extra"
		"http://llvm.org/git/clang-tools-extra.git"
		"12abebdfa999392dd7369f218157f50c50f1ce97"
)

EGIT_REPO_URI="http://llvm.org/git/llvm.git
	https://github.com/llvm-mirror/llvm.git"

LICENSE="UoI-NCSA"
SLOT="0"
KEYWORDS="-* amd64"
IUSE="+clang debug doc gold libedit +libffi multitarget ncurses ocaml python
	+static-analyzer test xml video_cards_radeon
	kernel_Darwin kernel_FreeBSD"

COMMON_DEPEND="
	sys-libs/zlib:0=
	clang? (
		python? ( ${PYTHON_DEPS} )
		static-analyzer? (
			dev-lang/perl:*
			${PYTHON_DEPS}
		)
		xml? ( dev-libs/libxml2:2= )
	)
	gold? ( >=sys-devel/binutils-2.22:*[cxx] )
	libedit? ( dev-libs/libedit:0=[${MULTILIB_USEDEP}] )
	libffi? ( >=virtual/libffi-3.0.13-r1:0=[${MULTILIB_USEDEP}] )
	ncurses? ( >=sys-libs/ncurses-5.9-r3:5=[${MULTILIB_USEDEP}] )
	ocaml? ( dev-lang/ocaml:0= )"
# configparser-3.2 breaks the build (3.3 or none at all are fine)
DEPEND="${COMMON_DEPEND}
	app-arch/xz-utils
	dev-lang/perl
	>=sys-devel/make-3.81
	>=sys-devel/flex-2.5.4
	>=sys-devel/bison-1.875d
	|| ( >=sys-devel/gcc-3.0 >=sys-devel/gcc-apple-4.2.1
		( >=sys-freebsd/freebsd-lib-9.1-r10 sys-libs/libcxx )
	)
	|| ( >=sys-devel/binutils-2.18 >=sys-devel/binutils-apple-5.1 )
	clang? ( xml? ( virtual/pkgconfig ) )
	doc? ( dev-python/sphinx )
	libffi? ( virtual/pkgconfig )
	!!<dev-python/configparser-3.3.0.2
	${PYTHON_DEPS}"
RDEPEND="${COMMON_DEPEND}
	clang? ( !<=sys-devel/clang-${PV}-r99
		!>=sys-devel/clang-9999 )
	abi_x86_32? ( !<=app-emulation/emul-linux-x86-baselibs-20130224-r2
		!app-emulation/emul-linux-x86-baselibs[-abi_x86_32(-)] )"
PDEPEND="clang? ( =sys-devel/clang-${PV}-r100 )"

# pypy gives me around 1700 unresolved tests due to open file limit
# being exceeded. probably GC does not close them fast enough.
REQUIRED_USE="${PYTHON_REQUIRED_USE}
	test? ( || ( $(python_gen_useflags 'python*') ) )"

#S=${WORKDIR}/${P/_}.src

# Some people actually override that in make.conf. That sucks since
# we need to run install per-directory, and ninja can't do that...
# so why did it call itself ninja in the first place?
#CMAKE_MAKEFILE_GENERATOR=emake

pkg_pretend() {
	# in megs
	# !clang !debug !multitarget -O2       400
	# !clang !debug  multitarget -O2       550
	#  clang !debug !multitarget -O2       950
	#  clang !debug  multitarget -O2      1200
	# !clang  debug  multitarget -O2      5G
	#  clang !debug  multitarget -O0 -g  12G
	#  clang  debug  multitarget -O2     16G
	#  clang  debug  multitarget -O0 -g  14G

	local build_size=550
	use clang && build_size=1200

	if use debug; then
		ewarn "USE=debug is known to increase the size of package considerably"
		ewarn "and cause the tests to fail."
		ewarn

		(( build_size *= 14 ))
	elif is-flagq -g || is-flagq -ggdb; then
		ewarn "The C++ compiler -g option is known to increase the size of the package"
		ewarn "considerably. If you run out of space, please consider removing it."
		ewarn

		(( build_size *= 10 ))
	fi

	# Multiply by number of ABIs :).
	local abis=( $(multilib_get_enabled_abis) )
	(( build_size *= ${#abis[@]} ))

	local CHECKREQS_DISK_BUILD=${build_size}M
	check-reqs_pkg_pretend

	if [[ ${MERGE_TYPE} != binary ]]; then
		echo 'int main() {return 0;}' > "${T}"/test.cxx || die
		ebegin "Trying to build a C++11 test program"
		if ! $(tc-getCXX) -std=c++11 -o /dev/null "${T}"/test.cxx; then
			eerror "LLVM-${PV} requires C++11-capable C++ compiler. Your current compiler"
			eerror "does not seem to support -std=c++11 option. Please upgrade your compiler"
			eerror "to gcc-4.7 or an equivalent version supporting C++11."
			die "Currently active compiler does not support -std=c++11"
		fi
		eend ${?}
	fi
}

pkg_setup() {
	pkg_pretend
}

src_unpack() {
    set -- "${EGIT_REPO_URIS[@]}"
        while [[ $# -gt 0 ]]; do
                ESVN_PROJECT=$1 \
                EGIT_SOURCEDIR="${S}/$2" \
                EGIT_REPO_URI=$3 \
                EGIT_COMMIT=$4 \
                git-2_src_unpack
                shift 4
        done
}

src_prepare() {

	epatch "${FILESDIR}"/clang-3.7-asan-default-path.patch
	epatch "${FILESDIR}"/clang-3.7-diasble-lsan.patch
	epatch "${FILESDIR}"/clang-3.7-odr-detection-level.patch
	epatch "${FILESDIR}"/llvm-3.7-override-detect-leaks.patch

	if use clang; then
		# Automatically select active system GCC's libraries, bugs #406163 and #417913
		epatch "${FILESDIR}"/clang-3.5-gentoo-runtime-gcc-detection-v3.patch

		epatch "${FILESDIR}"/clang-3.6-gentoo-install.patch
		epatch "${FILESDIR}"/clang-3.4-darwin_prefix-include-paths.patch
		eprefixify tools/clang/lib/Frontend/InitHeaderSearch.cpp
	fi

	if use prefix && use clang; then
		sed -i -e "/^CFLAGS /s@-Werror@-I${EPREFIX}/usr/include@" \
			projects/compiler-rt/make/platform/clang_*.mk || die
	fi

	# User patches
	epatch_user

	python_setup
}

src_configure() {
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile
}

src_install() {
	cmake-utils_src_install
	python_doscript "${S}"/projects/compiler-rt/lib/asan/scripts/asan_symbolize.py
}
