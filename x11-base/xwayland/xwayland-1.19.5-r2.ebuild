# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

XORG_DOC=doc
inherit xorg-2

MY_P="xorg-server-${PV}"
SRC_URI="${MY_P}.tar.bz2"
DESCRIPTION="XWayland"
SLOT="0/${PV}"
KEYWORDS="*"
IUSE="kvm_guest"

# This ebuild and source is based on x11-base/xorg-server so conflicts may occur
# depending on USE flags.
RDEPEND="
	!x11-base/xorg-server
	dev-libs/openssl
	>=dev-libs/wayland-1.3.0
	>=media-libs/mesa-10.3.4-r1
	>=x11-libs/libXfont2-2.0.1
	>=x11-libs/libxshmfence-1.1
	>=x11-libs/pixman-0.27.2
	>=x11-misc/xkeyboard-config-2.4.1-r3
	>=x11-apps/xkbcomp-1.2.3"

DEPEND="${RDEPEND}
	>=dev-libs/wayland-protocols-1.1
	>=sys-kernel/linux-headers-4.4-r16
	media-libs/libepoxy
	>=x11-libs/libdrm-2.4.46
	>=x11-libs/libxkbfile-1.0.4
	>=x11-libs/xtrans-1.3.5
	>=x11-misc/xbitmaps-1.0.1
	>=x11-proto/bigreqsproto-1.1.0
	>=x11-proto/compositeproto-0.4
	>=x11-proto/damageproto-1.1
	>=x11-proto/fixesproto-5.0
	>=x11-proto/fontsproto-2.1.3
	>=x11-proto/glproto-1.4.17-r1
	>=x11-proto/inputproto-2.3
	>=x11-proto/kbproto-1.0.3
	>=x11-proto/randrproto-1.5.0
	>=x11-proto/recordproto-1.13.99.1
	>=x11-proto/renderproto-0.11
	>=x11-proto/resourceproto-1.2.0
	>=x11-proto/scrnsaverproto-1.1
	>=x11-proto/trapproto-3.4.3
	>=x11-proto/videoproto-2.2.2
	>=x11-proto/xcmiscproto-1.2.0
	>=x11-proto/xextproto-7.2.99.901
	>=x11-proto/xf86dgaproto-2.0.99.1
	>=x11-proto/xf86rushproto-1.1.2
	>=x11-proto/xf86vidmodeproto-2.2.99.1
	>=x11-proto/xineramaproto-1.1.3
	>=x11-proto/xproto-7.0.31
	>=x11-proto/presentproto-1.0
	>=x11-proto/dri2proto-2.8
	>=x11-proto/dri3proto-1.0"

S="${WORKDIR}/${MY_P}"

src_prepare() {
	epatch "${FILESDIR}"/*.patch

	# Needed for patches that modify configure.ac
	eautoreconf
}

src_configure() {
	XORG_CONFIGURE_OPTIONS=(
		--enable-xwayland
		--disable-config-hal
		--disable-devel-docs
		--disable-docs
		--disable-linux-acpi
		--disable-xnest
		--disable-xorg
		--disable-xquartz
		--disable-xvfb
		--disable-xwin
		--sysconfdir="${EPREFIX}"/etc/X11
		--localstatedir="${EPREFIX}"/var
		--with-fontrootdir="${EPREFIX}"/usr/share/fonts
		--with-xkb-output="${EPREFIX}"/var/lib/xkb
		--without-dtrace
		--without-fop
		--with-os-vendor=Gentoo
		--with-sha1=libcrypto
	)

	if use kvm_guest; then
		XORG_CONFIGURE_OPTIONS+=(
			--with-xkb-bin-directory="/opt/google/cros-containers/bin"
		)
	fi

	xorg-2_src_configure
}
