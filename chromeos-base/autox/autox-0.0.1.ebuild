# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit toolchain-funcs

DESCRIPTION="Chrome OS autox program"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE=""

RDEPEND="dev-libs/libpcre
        x11-libs/libX11
        x11-libs/libXtst"

DEPEND="${RDEPEND}"

src_unpack() {
	local platform="${CHROMEOS_ROOT}/src/platform"
	mkdir -p "${S}/autox"	
	cp -a "${platform}/autox" "${S}" || die
	ln -s "${platform}/../third_party/chrome/files/base" "${S}" || die
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
	pushd autox	
	scons || die "autox compile failed."
	popd
}

src_install() {
	insinto "/usr/bin"
	doins "autox/autox"
}
