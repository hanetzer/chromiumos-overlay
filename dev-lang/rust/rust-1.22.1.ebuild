# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

PYTHON_COMPAT=( python2_7 )

inherit python-any-r1 versionator toolchain-funcs

if [[ ${PV} = *beta* ]]; then
	betaver=${PV//*beta}
	BETA_SNAPSHOT="${betaver:0:4}-${betaver:4:2}-${betaver:6:2}"
	MY_P="rustc-beta"
	SLOT="beta/${PV}"
	SRC="${BETA_SNAPSHOT}/rustc-beta-src.tar.gz"
	KEYWORDS=""
else
	ABI_VER="$(get_version_component_range 1-2)"
	SLOT="stable/${ABI_VER}"
	MY_P="rustc-${PV}"
	SRC="${MY_P}-src.tar.gz"
	KEYWORDS="*"
fi


STAGE0_VERSION="1.$(($(get_version_component_range 2) - 1)).0"
STAGE0_VERSION_CARGO="0.$(($(get_version_component_range 2))).0"
STAGE0_DATE="2017-10-12"
RUST_STAGE0_amd64="rustc-${STAGE0_VERSION}-x86_64-unknown-linux-gnu"

DESCRIPTION="Systems programming language from Mozilla"
HOMEPAGE="http://www.rust-lang.org/"

SRC_URI="https://static.rust-lang.org/dist/${SRC} -> rustc-${PV}-src.tar.gz
	https://static.rust-lang.org/dist/${STAGE0_DATE}/rust-std-${STAGE0_VERSION}-x86_64-unknown-linux-gnu.tar.gz -> rust-std-${STAGE0_VERSION}.tar.gz
	https://static.rust-lang.org/dist/${RUST_STAGE0_amd64}.tar.gz
	https://static.rust-lang.org/dist/cargo-${STAGE0_VERSION_CARGO}-x86_64-unknown-linux-gnu.tar.gz
"

LICENSE="|| ( MIT Apache-2.0 ) BSD-1 BSD-2 BSD-4 UoI-NCSA"

RESTRICT="binchecks strip"
REQUIRED_USE="amd64"

DEPEND="${PYTHON_DEPS}
	>=dev-lang/perl-5.0
"

PATCHES=(
	"${FILESDIR}"/0001-fix-target-armv7a-cros.patch
	"${FILESDIR}"/0002-add-target-armv7a-cros-linux.patch
	"${FILESDIR}"/0003-fix-unknown-vendors.patch
	"${FILESDIR}"/0004-fix-rpath.patch
	"${FILESDIR}"/0005-add-unknown-vendor-to-filesearch.patch
	# TODO(zachr): The linker build option is backported from master. According to the schedule,
	# these commits will be promoted to beta Nov 23rd, 2017, then released with 1.23 on Jan 4, 2018.
	"${FILESDIR}"/0006-rustbuild-Support-specifying-archiver-and-linker-exp.patch
	"${FILESDIR}"/0007-Don-t-use-target-s-linker-when-linking-build-scripts.patch
)

S="${WORKDIR}/${MY_P}-src"

src_prepare() {
	local stagename="RUST_STAGE0_${ARCH}"
	local stage0="${!stagename}"

	cp -r "${WORKDIR}"/rust-std-${STAGE0_VERSION}-x86_64-unknown-linux-gnu/rust-std-x86_64-unknown-linux-gnu/lib/rustlib/x86_64-unknown-linux-gnu \
		"${WORKDIR}"/${stage0}/rustc/lib/rustlib || die

	# armv7a is treated specially because the cros toolchain differs in
	# more than just the vendor part of the target triple. The arch is
	# armv7a in cros versus armv7 and the abi is gnueabi in cros verus
	# gnueabihf. This should no longer be needed after chromium:711369
	# is fixed.
	pushd src/librustc_back/target || die
	sed -e 's:"unknown":"cros":g' armv7_unknown_linux_gnueabihf.rs >armv7a_cros_linux_gnueabi.rs
	popd

	# One of the patches changes a vendored library, thereby changing the
	# checksum.
	pushd src/vendor/cc || die
	sed -i 's:5f254224f983fa9a5bae1c26bc94df6c434ba8a3ed0eb1deb8361dc0c6db3a41:2b12049076628a3d797fbddab46b8e69d2788faa809f3a03778880293b3d8a80:g' \
		.cargo-checksum.json
	popd


	# Tsk. Tsk. The rust makefile for LLVM's compiler-rt uses -ffreestanding
	# but one of the files includes <stdlib.h> causing occasional problems
	# with MB_LEN_MAX. See crbug.com/730845 for the thrilling details. This
	# line patches over the problematic include. This must go here because
	# src/compiler-rt is a submodule that only gets filled in after
	# ./configure.
	sed -e 's:#include <stdlib.h>:void abort(void);:g' \
		-i "${ECONF_SOURCE:-.}"/src/libcompiler_builtins/compiler-rt/lib/builtins/int_util.c || die

	epatch "${PATCHES[@]}"

	# For the librustc_llvm module, the build will link with -nodefaultlibs and manually choose the
	# std C++ library. For x86_64 Linux, the build script always chooses libstdc++ which will not
	# work if LLVM was built with USE="default-libcxx". This snippet changes that choice to libc++
	# in the case that clang++ defaults to libc++.
	if "${CXX}" -### -x c++ - < /dev/null 2>&1 | grep -q -e '-lc++'; then
		sed -i 's:"stdc++":"c++":g' src/librustc_llvm/build.rs || die
	fi

	default
}

src_configure() {
	local stagename="RUST_STAGE0_${ARCH}"
	local stage0="${!stagename}"

	cat > cros-config.toml <<EOF
[build]
target = ["x86_64-unknown-linux-gnu", "armv7a-cros-linux-gnueabi", "aarch64-unknown-linux-gnu"]
cargo = "${WORKDIR}/cargo-${STAGE0_VERSION_CARGO}-x86_64-unknown-linux-gnu/cargo/bin/cargo"
rustc = "${WORKDIR}/${stage0}/rustc/bin/rustc"
docs = false
submodules = false
python = "${EPYTHON}"
vendor = true

[llvm]
ninja = true

[install]
prefix = "${ED}usr"
libdir = "$(get_libdir)/rust"
mandir = "share/man"

[rust]
use-jemalloc = false
default-linker = "${CBUILD}-clang"
default-ar = "$(tc-getBUILD_AR)"
channel = "${SLOT%%/*}"
codegen-units = 0

[target.x86_64-unknown-linux-gnu]
cc = "x86_64-cros-linux-gnu-clang"
cxx = "x86_64-cros-linux-gnu-clang++"
linker = "x86_64-cros-linux-gnu-clang++"

[target.armv7a-cros-linux-gnueabi]
cc = "armv7a-cros-linux-gnueabi-clang"
cxx = "armv7a-cros-linux-gnueabi-clang++"
linker = "armv7a-cros-linux-gnueabi-clang++"

[target.aarch64-unknown-linux-gnu]
cc = "aarch64-cros-linux-gnu-clang"
cxx = "aarch64-cros-linux-gnu-clang++"
linker = "aarch64-cros-linux-gnu-clang++"
EOF

}

src_compile() {
	${EPYTHON} x.py build --config cros-config.toml || die
}

src_install() {
	local obj="build/x86_64-unknown-linux-gnu/stage2"
	dobin "${obj}/bin/rustc" "${obj}/bin/rustdoc"
	dobin src/etc/rust-gdb src/etc/rust-lldb
	insinto "/usr/$(get_libdir)"
	doins -r "${obj}/lib/"*
}
