# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

MY_PN=llvm
MY_P=${MY_PN}-${PV}
S="${WORKDIR}/${P}"

: ${CMAKE_MAKEFILE_GENERATOR:=ninja}
# (needed due to CMAKE_BUILD_TYPE != Gentoo)
CMAKE_MIN_VERSION=3.7.0-r1
PYTHON_COMPAT=( python2_7 )

inherit cmake-utils flag-o-matic multilib-minimal pax-utils \
	python-any-r1 toolchain-funcs versionator arc-build

DESCRIPTION="Low Level Virtual Machine"
HOMEPAGE="https://llvm.org/"
SRC_URI="https://releases.llvm.org/${PV/_//}/${MY_P/_/}.src.tar.xz"

# Keep in sync with CMakeLists.txt
ALL_LLVM_TARGETS=( AArch64 AMDGPU ARM BPF Hexagon Lanai Mips MSP430
	NVPTX PowerPC RISCV Sparc SystemZ X86 XCore )
ALL_LLVM_TARGETS=( "${ALL_LLVM_TARGETS[@]/#/llvm_targets_}" )

# Additional licenses:
# 1. OpenBSD regex: Henry Spencer's license ('rc' in Gentoo) + BSD.
# 2. ARM backend: LLVM Software Grant by ARM.
# 3. MD5 code: public-domain.
# 4. Tests (not installed):
#  a. gtest: BSD.
#  b. YAML tests: MIT.

LICENSE="UoI-NCSA rc BSD public-domain
	llvm_targets_ARM? ( LLVM-Grant )"
SLOT="$(get_major_version)"
KEYWORDS="*"
IUSE="debug -doc libedit libffi ncurses test
	elibc_musl kernel_Darwin ${ALL_LLVM_TARGETS[*]}"

S=${WORKDIR}/${MY_P/_/}.src

# least intrusive of all
CMAKE_BUILD_TYPE=RelWithDebInfo

python_check_deps() {
	! use test \
		|| has_version "dev-python/lit[${PYTHON_USEDEP}]"
}

src_prepare() {
	# Fix llvm-config for shared linking and sane flags
	# https://bugs.gentoo.org/show_bug.cgi?id=565358
	epatch "${FILESDIR}"/9999/0007-llvm-config-Clean-up-exported-values-update-for-shar.patch

	# support building llvm against musl-libc
	use elibc_musl && epatch "${FILESDIR}"/9999/musl-fixes.patch

	# disable use of SDK on OSX, bug #568758
	sed -i -e 's/xcrun/false/' utils/lit/lit/util.py || die

	# User patches
	epatch_user
}

build_host_tool() {
	local tool="$1"
	# Use host toolchain when building for the host.
	local CC=clang
	local CXX=clang++
	local CFLAGS=''
	local CXXFLAGS=''
	export HOST_DIR="${WORKDIR}/${PF}-${CBUILD}";
	mkdir -p "${HOST_DIR}" || die
	cd "${HOST_DIR}" || die
	local libdir=$(get_libdir)
	cmake -DLLVM_LIBDIR_SUFFIX=${libdir#lib} \
		-DLLVM_TARGETS_TO_BUILD="${LLVM_TARGETS// /;}" \
		-G "Unix Makefiles" ${S}
	# We don't build shared libraries on the host, but we want
	# llvm-config's output to match the target behavior, so override
	# the config embedded into the binary.
	sed -i -E '/LLVM_(LINK|ENABLE)_DYLIB 0/s:0:1:' \
		"${HOST_DIR}/${tool}/BuildVariables.inc"
	cd "${HOST_DIR}/${tool}" || die
	emake
}

build_host_tblgen() {
	build_host_tool "utils/TableGen"
}

build_host_config() {
	build_host_tool "tools/llvm-config"
	mv "${HOST_DIR}/bin/llvm-config" "${HOST_DIR}/bin/llvm-config-${ABI}"
}

create_llvmconfig_wrapper() {
	cat > "${LLVM_CONFIG_HOST}" <<EOF
#!/bin/bash
$1 "\${SYSROOT}"/usr/lib/llvm/bin/llvm-config "\$@"
EOF
}

create_llvmconfig_host() {
	export LLVM_CONFIG_HOST="${WORKDIR}/llvm-config-host"
	create_llvmconfig_wrapper
	if use arm; then
		rm "${LLVM_CONFIG_HOST}"
		create_llvmconfig_wrapper "qemu-arm -L ${SYSROOT}"
	fi

	if use arm64; then
		rm "${LLVM_CONFIG_HOST}"
		create_llvmconfig_wrapper "qemu-aarch64 -L ${SYSROOT}"
	fi


	chmod a+rx "${LLVM_CONFIG_HOST}"
}

src_configure() {
	arc-build-select-clang
	multilib-minimal_src_configure
}

multilib_src_configure() {
	local ffi_cflags ffi_ldflags
	if use libffi; then
		ffi_cflags=$($(tc-getPKG_CONFIG) --cflags-only-I libffi)
		ffi_ldflags=$($(tc-getPKG_CONFIG) --libs-only-L libffi)
	fi

	local libdir=$(get_libdir)
	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX="${ARC_PREFIX}/build"
		-DLLVM_LIBDIR_SUFFIX=${libdir#lib}

		-DLLVM_BUILD_LLVM_DYLIB=ON

		# Explicitly select the host and AMDGPU targets for building
		# AMDGPU drivers.
		-DLLVM_TARGETS_TO_BUILD="${LLVM_TARGETS// /;}"
		-DLLVM_BUILD_TESTS=$(usex test)
		-DLLVM_BUILD_TOOLS=OFF

		-DLLVM_ENABLE_FFI=$(usex libffi)
		-DLLVM_ENABLE_LIBEDIT=$(usex libedit)
		-DLLVM_ENABLE_TERMINFO=$(usex ncurses)
		-DLLVM_ENABLE_ASSERTIONS=$(usex debug)
		-DLLVM_ENABLE_EH=ON
		-DLLVM_ENABLE_RTTI=ON

		-DWITH_POLLY=OFF # TODO

		-DLLVM_HOST_TRIPLE="${CHOST}"

		-DFFI_INCLUDE_DIR="${ffi_cflags#-I}"
		-DFFI_LIBRARY_DIR="${ffi_ldflags#-L}"

		# disable OCaml bindings (now in dev-ml/llvm-ocaml)
		-DOCAMLFIND=NO
	)

#	Note: go bindings have no CMake rules at the moment
#	but let's kill the check in case they are introduced
#	if ! multilib_is_native_abi || ! use go; then
		mycmakeargs+=(
			-DGO_EXECUTABLE=GO_EXECUTABLE-NOTFOUND
		)
#	fi

	use test && mycmakeargs+=(
		-DLIT_COMMAND="${EPREFIX}/usr/bin/lit"
	)

	if multilib_is_native_abi; then
		mycmakeargs+=(
			-DLLVM_BUILD_DOCS=$(usex doc)
			-DLLVM_ENABLE_OCAMLDOC=OFF
			-DLLVM_ENABLE_SPHINX=$(usex doc)
			-DLLVM_ENABLE_DOXYGEN=OFF
			-DLLVM_INSTALL_UTILS=ON
		)
	fi

	if tc-is-cross-compiler; then
		build_host_tblgen
		# die early if the build tools are not installed
		[[ -x "${HOST_DIR}/bin/llvm-tblgen" ]] \
			|| die "${HOST_DIR}/bin/llvm-tblgen not found or usable"
		mycmakeargs+=(
			-DCMAKE_CROSSCOMPILING=ON
			-DLLVM_TABLEGEN="${HOST_DIR}/bin/llvm-tblgen"
		)
	fi

	# LLVM_ENABLE_ASSERTIONS=NO does not guarantee this for us, #614844
	use debug || local -x CPPFLAGS="${CPPFLAGS} -DNDEBUG"
	cmake-utils_src_configure
}

multilib_src_compile() {
	cmake-utils_src_compile

	pax-mark m "${BUILD_DIR}"/bin/llvm-rtdyld
	pax-mark m "${BUILD_DIR}"/bin/lli
	pax-mark m "${BUILD_DIR}"/bin/lli-child-target

	if use test; then
		pax-mark m "${BUILD_DIR}"/unittests/ExecutionEngine/Orc/OrcJITTests
		pax-mark m "${BUILD_DIR}"/unittests/ExecutionEngine/MCJIT/MCJITTests
		pax-mark m "${BUILD_DIR}"/unittests/Support/SupportTests
	fi

	build_host_config
}

multilib_src_test() {
	# respect TMPDIR!
	local -x LIT_PRESERVES_TMP=1
	cmake-utils_src_make check
}

src_install() {
	local LLVM_LDPATHS=()
	multilib-minimal_src_install
}

multilib_src_install() {
	cmake-utils_src_install
	into ${ARC_PREFIX}/build
	newbin "${HOST_DIR}/bin/llvm-config-${ABI}" "llvm-config-host-${ABI}"

	# Manually copy libLLVM-4.0.so into the android container.
	# TODO(teravest): Statically link with this instead of installing this
	# shared library.
	into "${ARC_PREFIX}/vendor"
	dolib $(get_libdir)/libLLVM-4.0.so
}

multilib_src_install_all() {
	local LLVM_CONFIG_HOST="${D}/${ARC_PREFIX}/build/bin/llvm-config-host"
	cat > "${LLVM_CONFIG_HOST}" <<EOF
#!/bin/bash

ABI_BIN="\$(dirname ""\$0"")/llvm-config-host-\${ABI}"

if [[ -e "\${ABI_BIN}" ]]; then
	exec "\${ABI_BIN}" "\$@"
else
	echo "\$0: Unsupported ABI: \${ABI}"
	exit 1
fi
EOF
	chmod a+rx "${LLVM_CONFIG_HOST}" || die
}
