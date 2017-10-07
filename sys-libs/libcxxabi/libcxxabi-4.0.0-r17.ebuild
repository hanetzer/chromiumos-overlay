# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT=("bb0e188762f569942766f8f25c9d38448c48cf9b" "b5b70be878fe8d29abe399950a4b3a74f9861f81" "328ecd4d5f69480e18eb872759a41b7ec7217283")
CROS_WORKON_TREE=("011e2ecc76376a3248284f1426728f123284f8f5" "bc57d9a17362a6b64ee1bdd2b13336423bafedb3" "95d97bef877a89451183d481c8fa848f9688a107")
: ${CMAKE_MAKEFILE_GENERATOR:=ninja}
PYTHON_COMPAT=( python2_7 )

inherit cros-constants

CROS_WORKON_REPO=${CROS_GIT_AOSP_URL}
CROS_WORKON_PROJECT=(
	"platform/external/libcxxabi"
	"platform/external/libcxx"
	"platform/external/libunwind_llvm"
)
CROS_WORKON_LOCALNAME=("../aosp/external/libcxxabi" "../aosp/external/libcxx" "../aosp/external/libunwind_llvm")

S+=".src"
CROS_WORKON_DESTDIR=(
	"${S}"
	"${S}/libcxx"
	"${S}/libunwind_llvm"
)

inherit cmake-multilib cros-llvm cros-workon flag-o-matic llvm python-any-r1

DESCRIPTION="Low level support for a standard C++ library"
HOMEPAGE="http://libcxxabi.llvm.org/"

LICENSE="|| ( UoI-NCSA MIT )"
SLOT="0"
KEYWORDS="*"
IUSE="+compiler-rt cros_host libunwind +static-libs test"

RDEPEND="
	libunwind? (
			|| (
				>=${CATEGORY}/libunwind-1[static-libs?,${MULTILIB_USEDEP}]
				>=${CATEGORY}/llvm-libunwind-3.9.0-r1[static-libs?,${MULTILIB_USEDEP}]
			)
	)"

DEPEND="${RDEPEND}
	cros_host? ( sys-devel/llvm )
	test? ( >=sys-devel/clang-3.9.0
		~sys-libs/libcxx-${PV}[libcxxabi(-)]
		$(python_gen_any_dep 'dev-python/lit[${PYTHON_USEDEP}]') )"

S=${WORKDIR}/${P/_/}.src

python_check_deps() {
	has_version "dev-python/lit[${PYTHON_USEDEP}]"
}

pkg_setup() {
	setup_cross_toolchain
	llvm_pkg_setup
	use test && python-any-r1_pkg_setup
}

src_prepare() {
	# Link with libgcc_eh when compiler-rt is used.
	epatch "${FILESDIR}"/libcxxabi-use-libgcc_eh.patch
}

multilib_src_configure() {
	# Use vpfv3 fpu to be able to target non-neon targets.
	if [[ $(tc-arch) == "arm" ]] ; then
		append-flags -mfpu=vfpv3
	fi
	append-flags -I"${S}/libunwind_llvm/include"
	append-flags "-stdlib=libstdc++"
	local libdir=$(get_libdir)
	local mycmakeargs=(
		-DLIBCXXABI_LIBDIR_SUFFIX=${libdir#lib}
		-DLIBCXXABI_ENABLE_SHARED=ON
		-DLIBCXXABI_ENABLE_STATIC=$(usex static-libs)
		-DLIBCXXABI_USE_LLVM_UNWINDER=$(usex libunwind)
		-DLIBCXXABI_INCLUDE_TESTS=$(usex test)
		-DCMAKE_INSTALL_PREFIX="${PREFIX}"
		-DLIBCXXABI_LIBCXX_INCLUDES="${S}"/libcxx/include
		-DLIBCXXABI_USE_COMPILER_RT=$(usex compiler-rt)
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
	if [[ ${CATEGORY} == cross-* ]]; then
		rm -r "${ED}/usr/share/doc"
	fi
	insinto "${PREFIX}"/include/libcxxabi
	doins -r include/.
}