# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit toolchain-funcs

DESCRIPTION="Screen locker for Chrome OS."
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE=""

RDEPEND="chromeos-base/pam_offline
	x11-libs/libXmu  
	x11-libs/libXrandr  
	x11-libs/libXt
	x11-libs/libX11
	x11-libs/libXext
        sys-libs/pam"

DEPEND="x11-proto/xextproto
	x11-proto/scrnsaverproto
	x11-proto/recordproto  
	sys-devel/bc	
	${RDEPEND}"

src_unpack() {
	local asset_images="${CHROMEOS_ROOT}/src/platform/assets/images"
	local third_party="${CHROMEOS_ROOT}/src/third_party"
	elog "Using third_party: $third_party"
	mkdir -p "${S}"
	cp -a "${third_party}/xscreensaver/xscreensaver-5.08"/* "${S}" || die
	mkdir -p "${S}/utils/images"
	cp "${asset_images}/screenlocker.xpm" "${S}/utils/images"
}

src_configure() {  
	econf --without-xf86vmode-ext --without-xf86gamma-ext  
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
	
	emake || die "xscreensaver compile failed."
}

src_install() {
	emake prefix="${D}/usr" install
	dodir "etc/X11/app-defaults"
	cp XScreenSaver "${D}/etc/X11/app-defaults/XScreenSaver"

	dodir "etc/pam.d"
	cp "${CHROMEOS_ROOT}/src/platform/screenlocker/portage-xscreensaver" \
	   "${D}/etc/pam.d/xscreensaver"
}
