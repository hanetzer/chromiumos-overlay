# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="2"
inherit toolchain-funcs

DESCRIPTION="The Mozc engine for IBus Framework"
HOMEPAGE="http://www.google.com/"
LICENSE="BSD"
RDEPEND=">=app-i18n/ibus-1.2"
DEPEND="${RDEPEND}"
SLOT="0"

BUILDTYPE="${BUILDTYPE:-Release}"
# TODO(mazda): Set the correct default path
MOZCDIR="${MOZCDIR:-files/mozc}"

src_unpack() {
  local src="${CHROMEOS_ROOT}/src/third_party/ibus-mozc/files"
  mkdir -p "${S}"
  cp -a "${src}" "${S}" || die
}

src_configure() {
  cd "${MOZCDIR}" || die

  # Generate make files
  export GYP_DEFINES="sysroot=${SYSROOT}"
  export BUILD_COMMAND="emake"
  python build_mozc.py gyp || die
}

src_compile() {
  cd "${MOZCDIR}" || die

  # Create build tools for the host platform.
  CFLAGS="" CXXFLAGS="" python build_mozc.py build_tools -c ${BUILDTYPE} || die

  # Build artifacts for the target platform.
  export CXX=$(tc-getCXX)
  export CC=$(tc-getCC)
  export AR=$(tc-getAR)
  export AS=$(tc-getAS)
  export RANLIB=$(tc-getRANLIB)
  export LD=$(tc-getLD)
  python build_mozc.py build unix:ibus_mozc -c ${BUILDTYPE} || die
}

src_install() {
  exeinto /usr/libexec || die
  # TODO(mazda): Specify the correct output path
  newexe "${MOZCDIR}"/out/${BUILDTYPE}/ibus_mozc ibus-engine-mozc || die

  insinto /usr/share/ibus/component || die
  doins "${MOZCDIR}"/unix/ibus/mozc.xml || die
}
