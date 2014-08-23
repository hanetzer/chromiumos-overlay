# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="bdacdbb02a445e1c220e33e6ab89f6eb90ee3560"
CROS_WORKON_TREE="4d36744d396f1853524a73e7adbdd481b23a452f"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_DESTDIR="${S}"

inherit cros-workon

DESCRIPTION="Log scripts used by userfeedback to report cros system information"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="+mmc X"

RDEPEND="chromeos-base/chromeos-init
	chromeos-base/chromeos-installer
	chromeos-base/modem-utilities
	chromeos-base/vboot_reference
	media-libs/fontconfig
	media-sound/alsa-utils
	sys-apps/hdparm
	mmc? ( sys-apps/mmc-utils )
	sys-apps/mosys
	sys-apps/net-tools
	sys-apps/pciutils
	sys-apps/smartmontools
	sys-apps/usbutils
	X? ( x11-apps/setxkbmap )"

DEPEND=""

src_unpack() {
	cros-workon_src_unpack
	S+="/userfeedback"
}

src_test() {
	test/storage_info_unit_test || die "Unit test failed"
}

src_install() {
	exeinto /usr/share/userfeedback/scripts
	doexe scripts/*

	insinto /usr/share/userfeedback/etc
	doins etc/*

	insinto /etc/init
	doins init/*
}
