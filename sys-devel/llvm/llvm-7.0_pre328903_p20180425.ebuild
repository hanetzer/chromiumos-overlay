# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

: ${CMAKE_MAKEFILE_GENERATOR:=ninja}
PYTHON_COMPAT=( python2_7 )

inherit  cros-constants check-reqs cmake-utils eutils flag-o-matic git-2 git-r3 \
	multilib multilib-minimal python-single-r1 toolchain-funcs pax-utils

DESCRIPTION="Low Level Virtual Machine"
HOMEPAGE="http://llvm.org/"
SRC_URI=""
EGIT_REPO_URI="http://llvm.org/git/llvm.git
	https://github.com/llvm-mirror/llvm.git"
LICENSE="UoI-NCSA"

if use llvm-next; then

# llvm:r328903 https://critique.corp.google.com/#review/191960518
EGIT_REPO_URIS=(
	"llvm"
		""
		"${CROS_GIT_HOST_URL}/chromiumos/third_party/llvm.git"
		"95561668f063fbcb8195bde05ecede721ece4ba4" # EGIT_COMMIT r328901
	"compiler-rt"
		"projects/compiler-rt"
		"${CROS_GIT_HOST_URL}/chromiumos/third_party/compiler-rt.git"
		"13c69d3bcd85a38da14fd28322b0b2f8b675d943" # EGIT_COMMIT r328849
	"clang"
		"tools/clang"
		"${CROS_GIT_HOST_URL}/chromiumos/third_party/clang.git"
		"e7408fe366bb18923fa360b069b4e4566203f34f" # EGIT_COMMIT r328903
	"clang-tidy"
		"tools/clang/tools/extra"
		"${CROS_GIT_HOST_URL}/chromiumos/third_party/llvm-clang-tools-extra.git"
		"96f2a40217bb32f63ccd4a7c34a4645066c10c89" # EGIT_COMMIT r328819
)
else
# llvm:r328903 https://critique.corp.google.com/#review/191960518
EGIT_REPO_URIS=(
	"llvm"
		""
		"${CROS_GIT_HOST_URL}/chromiumos/third_party/llvm.git"
		"95561668f063fbcb8195bde05ecede721ece4ba4" # EGIT_COMMIT r328901
	"compiler-rt"
		"projects/compiler-rt"
		"${CROS_GIT_HOST_URL}/chromiumos/third_party/compiler-rt.git"
		"13c69d3bcd85a38da14fd28322b0b2f8b675d943" # EGIT_COMMIT r328849
	"clang"
		"tools/clang"
		"${CROS_GIT_HOST_URL}/chromiumos/third_party/clang.git"
		"e7408fe366bb18923fa360b069b4e4566203f34f" # EGIT_COMMIT r328903
	"clang-tidy"
		"tools/clang/tools/extra"
		"${CROS_GIT_HOST_URL}/chromiumos/third_party/llvm-clang-tools-extra.git"
		"96f2a40217bb32f63ccd4a7c34a4645066c10c89" # EGIT_COMMIT r328819
)
fi

LICENSE="UoI-NCSA"
SLOT="0/${PV%%_*}"
KEYWORDS="-* amd64"
IUSE="debug +default-compiler-rt +default-libcxx doc libedit +libffi multitarget
	ncurses ocaml python llvm-next llvm-tot test xml video_cards_radeon"

COMMON_DEPEND="
	sys-libs/zlib:0=
	libedit? ( dev-libs/libedit:0=[${MULTILIB_USEDEP}] )
	libffi? ( >=virtual/libffi-3.0.13-r1:0=[${MULTILIB_USEDEP}] )
	ncurses? ( >=sys-libs/ncurses-5.9-r3:5=[${MULTILIB_USEDEP}] )
	ocaml? (
		>=dev-lang/ocaml-4.00.0:0=
		dev-ml/findlib
		dev-ml/ocaml-ctypes )"
# configparser-3.2 breaks the build (3.3 or none at all are fine)
DEPEND="${COMMON_DEPEND}
	dev-lang/perl
	>=sys-devel/make-3.81
	>=sys-devel/flex-2.5.4
	>=sys-devel/bison-1.875d
	|| ( >=sys-devel/gcc-3.0 >=sys-devel/llvm-3.5
		( >=sys-freebsd/freebsd-lib-9.1-r10 sys-libs/libcxx )
	)
	|| ( >=sys-devel/binutils-2.18 >=sys-devel/binutils-apple-5.1 )
	doc? ( dev-python/sphinx )
	libffi? ( virtual/pkgconfig )
	!!<dev-python/configparser-3.3.0.2
	ocaml? ( test? ( dev-ml/ounit ) )
	${PYTHON_DEPS}"
RDEPEND="${COMMON_DEPEND}
	abi_x86_32? ( !<=app-emulation/emul-linux-x86-baselibs-20130224-r2
		!app-emulation/emul-linux-x86-baselibs[-abi_x86_32(-)] )"

# pypy gives me around 1700 unresolved tests due to open file limit
# being exceeded. probably GC does not close them fast enough.
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

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

	if use debug; then
		ewarn "USE=debug is known to increase the size of package considerably"
		ewarn "and cause the tests to fail."
		ewarn

		(( build_size *= 14 ))
	elif is-flagq '-g?(gdb)?([1-9])'; then
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

trunk_src_unpack() {
	git-r3_fetch "http://llvm.org/git/compiler-rt.git
		https://github.com/llvm-mirror/compiler-rt.git"
	git-r3_fetch "http://llvm.org/git/clang.git
		https://github.com/llvm-mirror/clang.git"
	git-r3_fetch "http://llvm.org/git/clang-tools-extra.git
		https://github.com/llvm-mirror/clang-tools-extra.git"
	git-r3_fetch

	git-r3_checkout http://llvm.org/git/compiler-rt.git \
		"${S}"/projects/compiler-rt
	git-r3_checkout http://llvm.org/git/clang.git \
		"${S}"/tools/clang
	git-r3_checkout http://llvm.org/git/clang-tools-extra.git \
		"${S}"/tools/clang/tools/extra
	git-r3_checkout
}

src_unpack() {
	if use llvm-tot ; then
		trunk_src_unpack
		return
	fi
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

pick_cherries() {
	# clang
	local CHERRIES=""
	CHERRIES+=" e24a51cdceab90191d497d490b1787e7bffae757" # r329001
	CHERRIES+=" 0ac472786f10c72665ee90d26c32438533ff35bd" # r329099
	CHERRIES+=" d8ad1e8b8544eb135135984fd7d35499214dd232" # r329247
	CHERRIES+=" abb490ec962c6db7c2071ba9d1bd0cd60b4a1b3a" # r329300
	CHERRIES+=" 6f11d411da7302cfb1d049928a8222c649eef441" # r329512
	pushd "${S}"/tools/clang >/dev/null || die
	for cherry in ${CHERRIES}; do
		epatch "${FILESDIR}/cherry/${cherry}.patch"
	done
	popd >/dev/null || die

	# llvm
	CHERRIES=""
	CHERRIES+=" 4804b20184409ec68e3e1c029e23264147c997f6" # r328944
	CHERRIES+=" aa2d256782e57f9dc5a4421cef1d01444bb7fbb1" # r329030
	CHERRIES+=" 21a0c18174343502c9f2b546a01333d1c351d9c0" # r329657 (Modified to resolve conflicts)
	CHERRIES+=" 9f8f7c5e8ab12afcc92f51d0ed596ac0867eb0fa" # r329673 (Modified to resolve conflicts)
	CHERRIES+=" 1c5a9ad72a4a947e9d5a70834e12b041c6525810" # r329771
	CHERRIES+=" 1a785071aa52843bb70082c6b5acb1057bd67066" # r329822
	CHERRIES+=" 4c208ab0d79745e51886b3b14b97c3a1abd526f9" # r330264
	CHERRIES+=" bb1ae438ca59097e3e6106b1b4e715631150f419" # r330269
	pushd "${S}" >/dev/null || die
	for cherry in ${CHERRIES}; do
		epatch "${FILESDIR}/cherry/${cherry}.patch"
	done
	popd >/dev/null || die

	# compiler-rt
	CHERRIES=""
	pushd "${S}"/projects/compiler-rt >/dev/null || die
	for cherry in ${CHERRIES}; do
		epatch "${FILESDIR}/cherry/${cherry}.patch"
	done
	popd >/dev/null || die
}

pick_next_cherries() {
	# clang
	local CHERRIES=""
	CHERRIES+=" e24a51cdceab90191d497d490b1787e7bffae757" # r329001
	CHERRIES+=" 0ac472786f10c72665ee90d26c32438533ff35bd" # r329099
	CHERRIES+=" d8ad1e8b8544eb135135984fd7d35499214dd232" # r329247
	CHERRIES+=" abb490ec962c6db7c2071ba9d1bd0cd60b4a1b3a" # r329300
	CHERRIES+=" 6f11d411da7302cfb1d049928a8222c649eef441" # r329512
	pushd "${S}"/tools/clang >/dev/null || die
	for cherry in ${CHERRIES}; do
		epatch "${FILESDIR}/cherry/${cherry}.patch"
	done
	popd >/dev/null || die

	# llvm
	CHERRIES=""
	CHERRIES+=" 4804b20184409ec68e3e1c029e23264147c997f6" # r328944
	CHERRIES+=" aa2d256782e57f9dc5a4421cef1d01444bb7fbb1" # r329030
	CHERRIES+=" 21a0c18174343502c9f2b546a01333d1c351d9c0" # r329657 (Modified to resolve conflicts)
	CHERRIES+=" 9f8f7c5e8ab12afcc92f51d0ed596ac0867eb0fa" # r329673 (Modified to resolve conflicts)
	CHERRIES+=" 1c5a9ad72a4a947e9d5a70834e12b041c6525810" # r329771
	CHERRIES+=" 1a785071aa52843bb70082c6b5acb1057bd67066" # r329822
	CHERRIES+=" 4c208ab0d79745e51886b3b14b97c3a1abd526f9" # r330264
	CHERRIES+=" bb1ae438ca59097e3e6106b1b4e715631150f419" # r330269
	pushd "${S}" >/dev/null || die
	for cherry in ${CHERRIES}; do
		epatch "${FILESDIR}/cherry/${cherry}.patch"
	done
	popd >/dev/null || die

	# compiler-rt
	CHERRIES=""
	pushd "${S}"/projects/compiler-rt >/dev/null || die
	for cherry in ${CHERRIES}; do
		epatch "${FILESDIR}/cherry/${cherry}.patch"
	done
	popd >/dev/null || die
}

src_prepare() {
	if ! use llvm-tot ; then
		use llvm-next || pick_cherries
		use llvm-next && pick_next_cherries
	fi
	epatch "${FILESDIR}"/llvm-6.0-gnueabihf.patch
	epatch "${FILESDIR}"/llvm-7.0-mssa-bugfix.patch
	epatch "${FILESDIR}"/llvm-next-leak-whitelist.patch
	epatch "${FILESDIR}"/clang-4.0-asan-default-path.patch

	# This is need by thinlto on ARM.
	# Convert to cherry-picks once
	# https://reviews.llvm.org/D44792 and
	# https://reviews.llvm.org/D44788 are merged.
	epatch "${FILESDIR}"/llvm-7.0-flto-fission.patch

	# Make ocaml warnings non-fatal, bug #537308
	sed -e "/RUN/s/-warn-error A//" -i test/Bindings/OCaml/*ml  || die

	# Allow custom cmake build types (like 'Gentoo')
	epatch "${FILESDIR}"/cmake/${PN}-3.8-allow_custom_cmake_build_types.patch

	# crbug/591436
	epatch "${FILESDIR}"/clang-executable-detection.patch

	# crbug/606391
	epatch "${FILESDIR}"/${PN}-3.8-invocation.patch

	epatch "${FILESDIR}"/llvm-3.9-dwarf-version.patch

	# Link libgcc_eh when using compiler-rt as default rtlib.
	# https://llvm.org/bugs/show_bug.cgi?id=28681
	epatch "${FILESDIR}"/clang-6.0-enable-libgcc-with-compiler-rt.patch

	python_setup

	# User patches
	epatch_user

	# Native libdir is used to hold LLVMgold.so
	NATIVE_LIBDIR=$(get_libdir)
}

enable_asserts() {
	# Enable assertions for llvm-next build
	if use llvm-next || use llvm-tot; then
		echo yes
	else
		usex debug
	fi
}

multilib_src_configure() {
	local targets
	if use multitarget; then
		targets=all
	else
		targets='host;CppBackend'
		use video_cards_radeon && targets+=';AMDGPU'
	fi

	local ffi_cflags ffi_ldflags
	if use libffi; then
		ffi_cflags=$(pkg-config --cflags-only-I libffi)
		ffi_ldflags=$(pkg-config --libs-only-L libffi)
	fi

	local libdir=$(get_libdir)
	local mycmakeargs=(
		"${mycmakeargs[@]}"
		-DLLVM_LIBDIR_SUFFIX=${libdir#lib}

		-DLLVM_BUILD_LLVM_DYLIB=ON
		-DLLVM_LINK_LLVM_DYLIB=ON
		-DLLVM_ENABLE_TIMESTAMPS=OFF
		-DLLVM_TARGETS_TO_BUILD="${targets}"
		-DLLVM_BUILD_TESTS=$(usex test)

		-DLLVM_ENABLE_FFI=$(usex libffi)
		-DLLVM_ENABLE_TERMINFO=$(usex ncurses)
		-DLLVM_ENABLE_ASSERTIONS=$(enable_asserts)
		-DLLVM_ENABLE_EH=ON
		-DLLVM_ENABLE_RTTI=ON

		-DWITH_POLLY=OFF # TODO

		-DLLVM_HOST_TRIPLE="${CHOST}"

		-DFFI_INCLUDE_DIR="${ffi_cflags#-I}"
		-DFFI_LIBRARY_DIR="${ffi_ldflags#-L}"
		-DLLVM_BINUTILS_INCDIR="${SYSROOT}"/usr/include

		-DHAVE_HISTEDIT_H=$(usex libedit)
		-DENABLE_LINKER_BUILD_ID=ON
		-DCLANG_VENDOR="Chromium OS ${PVR}"
		# override default stdlib and rtlib
		-DCLANG_DEFAULT_CXX_STDLIB=$(usex default-libcxx libc++ "")
		-DCLANG_DEFAULT_RTLIB=$(usex default-compiler-rt compiler-rt "")
	)

	if ! multilib_is_native_abi || ! use ocaml; then
		mycmakeargs+=(
			-DOCAMLFIND=NO
		)
	fi
#	Note: go bindings have no CMake rules at the moment
#	but let's kill the check in case they are introduced
#	if ! multilib_is_native_abi || ! use go; then
		mycmakeargs+=(
			-DGO_EXECUTABLE=GO_EXECUTABLE-NOTFOUND
		)
#	fi

	if multilib_is_native_abi; then
		mycmakeargs+=(
			-DLLVM_BUILD_DOCS=$(usex doc)
			-DLLVM_ENABLE_SPHINX=$(usex doc)
			-DLLVM_ENABLE_DOXYGEN=OFF
			-DLLVM_INSTALL_HTML="${EPREFIX}/usr/share/doc/${PF}/html"
			-DSPHINX_WARNINGS_AS_ERRORS=OFF
			-DLLVM_INSTALL_UTILS=ON
		)
	fi
	cmake-utils_src_configure
}

multilib_src_compile() {
	cmake-utils_src_compile
	# TODO: not sure why this target is not correctly called
	multilib_is_native_abi && use doc && use ocaml && cmake-utils_src_make docs/ocaml_doc

	pax-mark m "${BUILD_DIR}"/bin/llvm-rtdyld
	pax-mark m "${BUILD_DIR}"/bin/lli
	pax-mark m "${BUILD_DIR}"/bin/lli-child-target

	if use test; then
		pax-mark m "${BUILD_DIR}"/unittests/ExecutionEngine/Orc/OrcJITTests
		pax-mark m "${BUILD_DIR}"/unittests/ExecutionEngine/MCJIT/MCJITTests
		pax-mark m "${BUILD_DIR}"/unittests/Support/SupportTests
	fi
}

multilib_src_test() {
	# respect TMPDIR!
	local -x LIT_PRESERVES_TMP=1
	local test_targets=( check )
	cmake-utils_src_make "${test_targets[@]}"
}

src_install() {
	local MULTILIB_CHOST_TOOLS=(
		/usr/bin/llvm-config
	)

	local MULTILIB_WRAPPED_HEADERS=(
		/usr/include/llvm/Config/config.h
		/usr/include/llvm/Config/llvm-config.h
	)

	multilib-minimal_src_install
}

multilib_src_install() {
	cmake-utils_src_install

	local wrapper_script=clang_host_wrapper
	cat "${FILESDIR}/clang_host_wrapper.header" \
		"${FILESDIR}/wrapper_script_common" \
		"${FILESDIR}/clang_host_wrapper.body" > \
		"${D}/usr/bin/${wrapper_script}" || die
	chmod 755 "${D}/usr/bin/${wrapper_script}" || die
	newbin "${D}/usr/bin/clang-tidy" "clang-tidy"
	dobin "${FILESDIR}/bisect_driver.py"
	dobin "${FILESDIR}/clang-tidy-parse-build-log.py"
	dobin "${FILESDIR}/clang-tidy-warn.py"
	dobin "${FILESDIR}/clang_tidy_execute.py"
	exeinto "/usr/bin"
	dosym "${wrapper_script}" "/usr/bin/${CHOST}-clang"
	dosym "${wrapper_script}" "/usr/bin/${CHOST}-clang++"
}

multilib_src_install_all() {
	insinto /usr/share/vim/vimfiles
	doins -r utils/vim/*/.
	# some users may find it useful
	dodoc utils/vim/vimrc
	dobin "${S}/projects/compiler-rt/lib/asan/scripts/asan_symbolize.py"
}
