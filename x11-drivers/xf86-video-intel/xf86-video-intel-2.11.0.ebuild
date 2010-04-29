# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-drivers/xf86-video-intel/xf86-video-intel-2.11.0.ebuild,v 1.1 2010/04/01 21:39:23 remi Exp $

EAPI=2
inherit x-modular

DESCRIPTION="X.Org driver for Intel cards"

KEYWORDS="~amd64 ~ia64 ~x86 ~x86-fbsd"
IUSE="dri"

RDEPEND=">=x11-base/xorg-server-1.6
	>=x11-libs/libdrm-2.4.16
	x11-libs/libpciaccess
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXvMC
	>=x11-libs/libxcb-1.5"
DEPEND="${RDEPEND}
	>=x11-proto/dri2proto-1.99.3
	x11-proto/fontsproto
	x11-proto/randrproto
	x11-proto/renderproto
	x11-proto/xextproto
	x11-proto/xproto
	dri? ( x11-proto/xf86driproto
	       x11-proto/glproto )"

PATCHES=(
	"${FILESDIR}/meego-${PV}-copy-fb.patch"
)

pkg_setup() {
	if tc-is-cross-compiler ; then
		local temp="${SYSROOT//\//_}"
		local ac_sysroot="${temp//-/_}"
		local ac_include_prefix="ac_cv_file_${ac_sysroot}_usr_include"
		eval export ${ac_include_prefix}_xorg_dri_h=yes
		eval export ${ac_include_prefix}_xorg_sarea_h=yes
		eval export ${ac_include_prefix}_xorg_dristruct_h=yes
	fi

	CONFIGURE_OPTIONS="$(use_enable dri) --enable-xvmc"
}
