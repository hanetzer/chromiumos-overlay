# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="2"
inherit eutils flag-o-matic python toolchain-funcs

DESCRIPTION="The Mozc Hangul engine for IBus Framework"
HOMEPAGE="http://code.google.com/p/mozc"
SRC_URI="http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/mozc-${PV}.tar.bz2"
LICENSE="BSD"
RDEPEND=">=app-i18n/ibus-1.3.99
         >=app-i18n/libhangul-0.0.10
         dev-libs/protobuf
         net-misc/curl"
DEPEND="${RDEPEND}"
SLOT="0"
KEYWORDS="amd64 x86 arm"
BUILDTYPE="${BUILDTYPE:-Release}"

src_prepare() {
  cd "mozc-${PV}" || die
  # Remove the epatch lines when mozc is upgraded.

  epatch "${FILESDIR}"/${P}-too-big-binary.patch
  epatch "${FILESDIR}"/${P}-does-not-work-hanja-key-binding.patch
  epatch "${FILESDIR}"/${P}-enable-comment.patch
  # issued as http://crosbug.com/18387
  epatch "${FILESDIR}"/${P}-unable-select-cand-by-num.patch
  # issued as http://crosbug.com/18419
  epatch "${FILESDIR}"/${P}-disappear-on-BSkey.patch
  # issued as http://crosbug.com/18454
  epatch "${FILESDIR}"/${P}-SPkey-does-not-work.patch
  # issued as http://crosbug.com/18507
  epatch "${FILESDIR}"/${P}-disappear-preedit-on-switch-ime.patch
  # issued as http://crosbug.com/18419 and http://crosbug.com/19074
  epatch "${FILESDIR}"/${P}-BSkey-and-modified-key-doesnt-work.patch
  # issued as http://crosbug.com/18555
  epatch "${FILESDIR}"/${P}-focusout-preedit-discard.patch
  # issued as http://crosbug.com/15947
  epatch "${FILESDIR}"/${P}-enable-won-key-input.patch
}

src_configure() {
  cd "mozc-${PV}" || die
  # Generate make files
  export GYP_DEFINES="chromeos=1 use_libzinnia=0"
  export BUILD_COMMAND="emake"

  # Currently --channel_dev=0 is not neccessary for Hangul, but just in case.
  $(PYTHON) build_mozc.py gyp --gypdir="third_party/gyp" \
      --hangul \
      --noqt \
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
      hangul/hangul.gyp:ibus_mozc_hangul -c ${BUILDTYPE} || die
}

src_install() {
  cd "mozc-${PV}" || die
  exeinto /usr/libexec || die
  newexe "out_linux/${BUILDTYPE}/ibus_mozc_hangul" ibus-engine-mozc-hangul \
      || die

  insinto /usr/share/ibus/component || die
  doins hangul/unix/ibus/mozc-hangul.xml || die

  cp "out_linux/${BUILDTYPE}/ibus_mozc_hangul" "${T}" || die
  $(tc-getSTRIP) --strip-unneeded "${T}"/ibus_mozc_hangul || die

  # Check the binary size to detect binary size bloat (which happend once due
  # typos in .gyp files). Current size of the stripped ibus-mozc-hangul binary
  # is about 900k (x86) and 700k (arm).
  test `stat -c %s "${T}"/ibus_mozc_hangul` -lt 1500000 \
      || die 'The binary size of mozc hangul is too big (more than ~1.5MB)'
  rm -f "${T}"/ibus_mozc_hangul
}
