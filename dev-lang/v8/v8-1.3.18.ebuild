# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit subversion toolchain-funcs

DESCRIPTION="V8 JavaScript engine."
HOMEPAGE="http://code.google.com/p/v8/"
SRC_URI=""
ESVN_REPO_URI="http://v8.googlecode.com/svn/trunk@4565"
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE=""

src_compile() {
  if tc-is-cross-compiler ; then
    tc-getCC
    tc-getCXX
    tc-getAR
    tc-getRANLIB
    tc-getLD
    tc-getNM
  fi

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
}

src_install() {
  dolib libv8.a

  insinto /usr/include
  doins include/v8.h
}
