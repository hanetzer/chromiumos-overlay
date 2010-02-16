# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit toolchain-funcs

DESCRIPTION="Chrome OS base library."
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE=""

DEPEND="x11-libs/libX11
	x11-proto/inputproto
	x11-proto/xproto"

RDEPEND=""

src_unpack() {
	local synaptics="${CHROMEOS_ROOT}/src/third_party/synaptics/"
	mkdir -p "${S}"
	cp -a "${synaptics}"/* "${S}" || die
}

src_compile() {
	if tc-is-cross-compiler ; then
		tc-getCC
		tc-getCXX
		tc-getAR
		tc-getRANLIB
		tc-getLD
		tc-getNM
		export PKG_CONFIG_PATH="${ROOT}/usr/lib/pkgconfig/"
		export CCFLAGS="$CFLAGS"
	fi

	scons || die "third_party/synaptics compile failed."
}

src_install() {
	mkdir -p "${D}/usr/lib" \
		"${D}/usr/include/"

	install -m0644 "${S}/synclient.h" "${D}/usr/include/"
	install -m0644 "${S}/libsynaptics.a" "${D}/usr/lib/"
}
