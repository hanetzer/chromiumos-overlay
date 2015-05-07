# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="a53573ae32ca50c9df56d96e42564962ba0a5fdc"
CROS_WORKON_TREE="1c1dddef178677f5a25da1deb26610278193ef13"
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
