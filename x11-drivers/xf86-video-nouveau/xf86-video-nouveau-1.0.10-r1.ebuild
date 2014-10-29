# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-drivers/xf86-video-nouveau/xf86-video-nouveau-1.0.10.ebuild,v 1.5 2014/04/16 07:44:16 ago Exp $

EAPI=4
XORG_DRI="always"
inherit xorg-2

if [[ ${PV} == 9999* ]]; then
	EGIT_REPO_URI="git://anongit.freedesktop.org/git/nouveau/${PN}"
	SRC_URI=""
fi

DESCRIPTION="Accelerated Open Source driver for nVidia cards"
HOMEPAGE="http://nouveau.freedesktop.org/"

KEYWORDS="*"
IUSE="udev"

RDEPEND="udev? ( virtual/udev )
	>=x11-libs/libdrm-2.4.34[video_cards_nouveau]"
DEPEND="${RDEPEND}"

src_prepare() {
	xorg-2_src_prepare

	# There is no configure knob for this, so hack it.
	use udev || export LIBUDEV_{CFLAGS,LIBS}=' '
	sed -i \
		-e "/LIBUDEV=/s:=.*:=$(usex udev):" \
		configure || die
}
