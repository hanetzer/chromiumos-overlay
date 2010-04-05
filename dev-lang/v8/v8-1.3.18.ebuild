# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit toolchain-funcs

DESCRIPTION="V8 JavaScript engine."
HOMEPAGE="http://code.google.com/p/v8/"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE=""

src_unpack() {
  local third_party="${CHROMEOS_ROOT}/src/third_party"
  elog "Using third_party: $third_party"
  mkdir -p "${S}/v8"
  cp -a "${third_party}/v8" "${S}" || die
}

src_compile() {
  if tc-is-cross-compiler ; then
    tc-getCC
    tc-getCXX
    tc-getAR
    tc-getRANLIB
    tc-getLD
    tc-getNM
  fi

  pushd v8

  # The v8 SConstruct file adds this flag when building dtoa on gcc 4.4, but
  # the build also fails when building src/handles-inl.h
  # with "src/handles-inl.h:50: error: dereferencing pointer '<anonymous>'
  # does break strict-aliasing rules".
  # See http://code.google.com/p/v8/issues/detail?id=463
  export CCFLAGS="$CCFLAGS -fno-strict-aliasing"
  export GCC_VERSION="44"

  local arch=""

  if use "x86"; then
    arch="ia32"
  elif use "amd64"; then
    arch="x64"
  elif use "arm"; then
    arch="arm"
  else
    die "Unknown architecture"
  fi

  scons arch=$arch importenv='SYSROOT,CCFLAGS,CC,CXX,AR,RANLIB,LD,NM' \
    || die "v8 compile failed."

  popd
}

src_install() {
  dolib "v8/libv8.a"

  insinto "/usr/include/"
  doins "v8/include/v8.h" 
}

