# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

: ${CMAKE_MAKEFILE_GENERATOR:=ninja}
PYTHON_COMPAT=( python2_7 )

inherit cmake-multilib cros-llvm flag-o-matic llvm python-any-r1

DESCRIPTION="Low level support for a standard C++ library"
HOMEPAGE="http://libcxxabi.llvm.org/"
SRC_URI="http://releases.llvm.org/${PV/_//}/${P/_/}.src.tar.xz
	http://releases.llvm.org/${PV/_//}/libcxx-${PV/_/}.src.tar.xz
	http://releases.llvm.org/${PV/_//}/libunwind-${PV/_/}.src.tar.xz
	"

LICENSE="|| ( UoI-NCSA MIT )"
SLOT="0"
KEYWORDS="*"
IUSE="+libunwind +static-libs test"


RDEPEND="
	libunwind? (
			|| (
				>=${CATEGORY}/libunwind-1[static-libs?,${MULTILIB_USEDEP}]
				>=${CATEGORY}/llvm-libunwind-3.9.0-r1[static-libs?,${MULTILIB_USEDEP}]
			)
	)"

DEPEND="${RDEPEND}
	test? ( >=sys-devel/clang-3.9.0
		~sys-libs/libcxx-${PV}[libcxxabi(-)]
		$(python_gen_any_dep 'dev-python/lit[${PYTHON_USEDEP}]') )"

S=${WORKDIR}/${P/_/}.src

python_check_deps() {
	has_version "dev-python/lit[${PYTHON_USEDEP}]"
}

pkg_setup() {
	export ABI="default"
	export MULTILIB_ABIS="default"
	export DEFAULT_ABI="default"
	setup_cross_toolchain
	llvm_pkg_setup
	use test && python-any-r1_pkg_setup
}

src_unpack() {
	default

	mv libcxx-* libcxx || die
}

multilib_src_configure() {
	# Add neon fpu for armv7a
	if [[ ${CATEGORY} == cross-armv7a* ]] ; then
		append-flags -mfpu=neon
	fi

	local libdir=$(get_libdir)
	local mycmakeargs=(
		-DLIBCXXABI_LIBDIR_SUFFIX=${libdir#lib}
		-DLIBCXXABI_ENABLE_SHARED=ON
		-DLIBCXXABI_ENABLE_STATIC=$(usex static-libs)
		-DLIBCXXABI_USE_LLVM_UNWINDER=$(usex libunwind)
		-DLIBCXXABI_INCLUDE_TESTS=$(usex test)
		-DCMAKE_INSTALL_PREFIX="${PREFIX}"

		-DLIBCXXABI_LIBCXX_INCLUDES="${WORKDIR}"/libcxx/include
		# upstream is omitting standard search path for this
		# probably because gcc & clang are bundling their own unwind.h
		-DLIBCXXABI_LIBUNWIND_INCLUDES="${EPREFIX}"/usr/include
		-DLIBCXXABI_LIBUNWIND_INCLUDES_INTERNAL="${WORKDIR}/libunwind-${PV/_/}.src/include"

		# this only needs to exist, it does not have to make sense
		# FIXME: remove this once https://reviews.llvm.org/D25314 is merged
		-DLIBCXXABI_LIBUNWIND_SOURCES="${WORKDIR}/libunwind-${PV/_/}.src/"
	)
	if use test; then
		mycmakeargs+=(
			-DLIT_COMMAND="${EPREFIX}"/usr/bin/lit
		)
	fi
	cmake-utils_src_configure
}

multilib_src_test() {
	local clang_path=$(type -P "${CHOST:+${CHOST}-}clang" 2>/dev/null)

	[[ -n ${clang_path} ]] || die "Unable to find ${CHOST}-clang for tests"
	sed -i -e "/cxx_under_test/s^\".*\"^\"${clang_path}\"^" test/lit.site.cfg || die

	cmake-utils_src_make check-libcxxabi
}

multilib_src_install_all() {
	insinto "${PREFIX}"/include/libcxxabi
	doins -r include/.
}
