# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="2"
inherit python toolchain-funcs

DESCRIPTION="The Mozc engine for IBus Framework"
HOMEPAGE="http://code.google.com/p/mozc"
SRC_URI="http://build.chromium.org/mirror/chromiumos/localmirror/distfiles/${PN}-svn-${PV}.tar.gz"
LICENSE="BSD"
RDEPEND=">=app-i18n/ibus-1.2
         dev-libs/protobuf
         net-misc/curl"
DEPEND="${RDEPEND}
        dev-python/gyp"
SLOT="0"
KEYWORDS="amd64 x86 arm"
BUILDTYPE="${BUILDTYPE:-Release}"
BRANDING="${BRANDING:-Mozc}"

src_unpack() {
	unpack ${A}
	cd "${S}"
}

src_configure() {
  # Generate make files
  local python_dir="/usr/$(get_libdir)/python$(python_get_version)"
  export PYTHONPATH="${SYSROOT}${python_dir}/site-packages"
  export GYP_DEFINES="chromeos=1"
  export BUILD_COMMAND="emake"

  $(PYTHON) build_mozc.py gyp --gypdir="${SYSROOT}/usr/bin" \
      --branding="${BRANDING}" || die
}

src_compile() {
  # Create build tools for the host platform.
  CFLAGS="" CXXFLAGS="" $(PYTHON) build_mozc.py build_tools -c ${BUILDTYPE} \
      || die

  # Build artifacts for the target platform.
  tc-export CXX CC AR AS RANLIB LD
  $(PYTHON) build_mozc.py build unix/ibus/ibus.gyp:ibus_mozc -c ${BUILDTYPE} \
      || die
}

src_install() {
  exeinto /usr/libexec || die
  newexe "out_linux/${BUILDTYPE}/ibus_mozc" ibus-engine-mozc || die

  insinto /usr/share/ibus/component || die
  doins out_linux/${BUILDTYPE}/obj/gen/unix/ibus/mozc.xml || die
}
