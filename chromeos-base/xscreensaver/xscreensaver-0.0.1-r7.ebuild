# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit cros-workon

DESCRIPTION="Screen locker for Chrome OS."
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE=""

RDEPEND="chromeos-base/chromeos-assets
    chromeos-base/pam_offline
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
	# Force category to be original for xscreensaver.
	CATEGORY="x11-misc"
	cros-workon_src_unpack
	
	# Get screenlocker image from chromeos-assets.
	local asset_images="${SYSROOT}/usr/share/chromeos-assets/images"
	mkdir -p "${S}/xscreensaver-5.08/utils/images"
	cp "${asset_images}/screenlocker.xpm" \
		"${S}/xscreensaver-5.08/utils/images" || die
}

src_configure() {
	pushd xscreensaver-5.08
	econf --without-xf86vmode-ext --without-xf86gamma-ext
	popd
}

src_compile() {
	pushd xscreensaver-5.08
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
	popd
}

src_install() {
	pushd xscreensaver-5.08
	emake prefix="${D}/usr" install || die "Install failed"

	insinto "/etc/X11/app-defaults"
	doins XScreenSaver

	insinto "/etc/pam.d"
	doins "pam.d/xscreensaver"
	popd
}
