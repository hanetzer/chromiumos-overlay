# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="5ffdcf1ceeb31a03fdd626187f377aa7268f94b5"
CROS_WORKON_TREE="a85922e3ce5df394f8c789c7dd260f4f05656b81"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_DESTDIR="${S}"

inherit cros-workon systemd

DESCRIPTION="Log scripts used by userfeedback to report cros system information"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="+mmc systemd X"

RDEPEND="chromeos-base/chromeos-init
	chromeos-base/chromeos-installer
	chromeos-base/crash-reporter
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

	# Install init scripts.
	if use systemd; then
		local units=("mosys-info.service" "firmware-version.service"
			"storage-info.service")
		systemd_dounit init/*.service
		for unit in "${units[@]}"; do
			systemd_enable_service system-services.target ${unit}
		done
	else
		insinto /etc/init
		doins init/*.conf
	fi
}
