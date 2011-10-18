# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="2"
inherit eutils flag-o-matic python toolchain-funcs

DESCRIPTION="The Mozc Chewing engine for IBus Framework"
HOMEPAGE="http://code.google.com/p/mozc"
SRC_URI="http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/mozc-${PV}.tar.bz2"
LICENSE="BSD"
RDEPEND=">=app-i18n/ibus-1.3.99.20110817
	 >=dev-libs/libchewing-0.3.2
         dev-libs/protobuf
         net-misc/curl"
DEPEND="${RDEPEND}"
SLOT="0"
KEYWORDS="amd64 x86 arm"
BUILDTYPE="${BUILDTYPE:-Release}"

src_prepare() {
  cd "mozc-${PV}" || die
  epatch "${FILESDIR}"/ibus-mozc-chewing-1.1.773.102-fix-property-string.patch
  epatch "${FILESDIR}"/ibus-mozc-chewing-1.2.855.102-support-numpad.patch
}

src_configure() {
  cd "mozc-${PV}" || die
  # Generate make files
  export GYP_DEFINES="chromeos=1 use_libzinnia=0"
  export BUILD_COMMAND="emake"

  # Currently --channel_dev=0 is not neccessary for Chewing, but just in case.
  $(PYTHON) build_mozc.py gyp --gypdir="third_party/gyp" \
      --chewing \
      --target_platform="ChromeOS" --channel_dev=0 || die
}

src_compile() {
  cd "mozc-${PV}" || die
  # Create build tools for the host platform.
  CFLAGS="" CXXFLAGS="" $(PYTHON) build_mozc.py build_tools -c ${BUILDTYPE} \
      || die

  # Build artifacts for the target platform.
  tc-export CXX CC AR AS RANLIB LD
  $(PYTHON) build_mozc.py build \
      chewing/chewing.gyp:ibus_mozc_chewing -c ${BUILDTYPE} || die
}

src_install() {
  cd "mozc-${PV}" || die
  exeinto /usr/libexec || die
  newexe "out_linux/${BUILDTYPE}/ibus_mozc_chewing" ibus-engine-mozc-chewing \
      || die

  insinto /usr/share/ibus/component || die
  doins chewing/unix/ibus/mozc-chewing.xml || die

  cp "out_linux/${BUILDTYPE}/ibus_mozc_chewing" "${T}" || die
  $(tc-getSTRIP) --strip-unneeded "${T}"/ibus_mozc_chewing || die

  # Check the binary size to detect binary size bloat (which happend once due
  # typos in .gyp files). Current size of the stripped ibus-mozc-chewing binary
  # is about 900k (x86) and 700k (arm).
  test `stat -c %s "${T}"/ibus_mozc_chewing` -lt 1500000 \
      || die 'The binary size of mozc chewing is too big (more than ~1.5MB)'
  rm -f "${T}"/ibus_mozc_chewing
}
