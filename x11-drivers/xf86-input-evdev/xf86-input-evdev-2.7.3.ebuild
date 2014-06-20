# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-drivers/xf86-input-evdev/xf86-input-evdev-2.7.3.ebuild,v 1.1 2012/08/14 01:24:15 chithanh Exp $

EAPI=4
XORG_EAUTORECONF=yes

inherit xorg-2

DESCRIPTION="Generic Linux input driver"
KEYWORDS="*"
IUSE=""
RDEPEND="chromeos-base/touch_noise_filter
	>=x11-base/xorg-server-1.10[udev]
	sys-fs/udev
	sys-libs/mtdev"
DEPEND="${RDEPEND}
	>=x11-proto/inputproto-2.1.99.3
	>=sys-kernel/linux-headers-2.6"

PATCHES=(
	"${FILESDIR}"/evdev-2.7.0-Use-monotonic-timestamps-for-input-events-if-availab.patch
        # crosbug.com/35291
	"${FILESDIR}"/evdev-2.7.3-Add-SYN_DROPPED-handling.patch
	"${FILESDIR}/evdev-disable-smooth-scrolling.patch"
	"${FILESDIR}/evdev-2.6.99-wheel-accel.patch"
	"${FILESDIR}"/evdev-2.7.0-feedback-log.patch
	"${FILESDIR}"/evdev-2.7.0-add-touch-event-timestamp.patch
	# crosbug.com/p/13787
	"${FILESDIR}"/evdev-2.7.0-fix-emulated-wheel.patch
	"${FILESDIR}"/evdev-2.7.0-add-block-reading-support.patch
	"${FILESDIR}"/evdev-2.7.3-Filer-touch-noise.patch
	"${FILESDIR}"/evdev-2.7.3-wheel_emu_when_no_real_wheel.patch
	"${FILESDIR}"/evdev-2.7.3-limit_num_slots.patch
        # crbug.com/343983
	"${FILESDIR}"/evdev-2.7.3-add-property-Enable-Debug-Log.patch
)
