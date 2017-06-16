# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-misc/xkeyboard-config/xkeyboard-config-2.15.ebuild,v 1.1 2015/07/04 10:00:59 mrueg Exp $

EAPI=5

XORG_STATIC=no
inherit xorg-2

EGIT_REPO_URI="git://anongit.freedesktop.org/git/xkeyboard-config"

DESCRIPTION="X keyboard configuration database"
HOMEPAGE="http://www.freedesktop.org/wiki/Software/XKeyboardConfig"
[[ ${PV} == *9999* ]] || SRC_URI="${XORG_BASE_INDIVIDUAL_URI}/data/${PN}/${P}.tar.bz2"

KEYWORDS="*"
IUSE="cros_host parrot"

LICENSE="MIT"
SLOT="0"

DEPEND="cros_host? ( >=x11-apps/xkbcomp-1.2.3 )
	dev-util/intltool
	>=x11-proto/xproto-7.0.20"

XORG_CONFIGURE_OPTIONS=(
	--with-xkb-base="${EPREFIX}/usr/share/X11/xkb"
	--enable-compat-rules
	# do not check for runtime deps
	--disable-runtime-deps
	--with-xkb-rules-symlink=xorg
)

PATCHES=(
	"${FILESDIR}"/${P}-gb-dvorak-deadkey.patch
	"${FILESDIR}"/${P}-colemack-neo-capslock-remap.patch
	"${FILESDIR}"/${P}-remap-capslock.patch
	"${FILESDIR}"/${P}-add-f19-24.patch
	"${FILESDIR}"/${P}-gb-extd-deadkey.patch
	"${FILESDIR}"/${P}-remap-f15-as-mod2mask.patch
	"${FILESDIR}"/${P}-canadian-french-international-backslash-fix.patch
	"${FILESDIR}"/${P}-ch-brokenbar.patch
	"${FILESDIR}"/${P}-br-euro-degree.patch
	"${FILESDIR}"/${P}-es-euro-sign.patch
	"${FILESDIR}"/${P}-tr-lira-sign.patch
	"${FILESDIR}"/${P}-fr-keypad-comma.patch
	"${FILESDIR}"/${P}-us-intl-pc.patch
)

use parrot && PATCHES+=( "${FILESDIR}"/${P}-parrot-euro-sign.patch )

src_prepare() {
	xorg-2_src_prepare
	if [[ ${XORG_EAUTORECONF} != no ]]; then
		intltoolize --copy --automake || die
	fi
}

src_compile() {
	# cleanup to make sure .dir files are regenerated
	# bug #328455 c#26
	xorg-2_src_compile clean
	xorg-2_src_compile
}
