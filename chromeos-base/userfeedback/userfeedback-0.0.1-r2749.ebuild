# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="54f07dbdd4ad2cfa2054c1bade78c8d5268ba1c9"
CROS_WORKON_TREE="7a4ea1a7dcbfa882697dbb3f03f744ca6b3266ed"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_DESTDIR="${S}"

inherit cros-workon systemd

DESCRIPTION="Log scripts used by userfeedback to report cros system information"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="systemd X"

RDEPEND="chromeos-base/chromeos-init
	chromeos-base/crash-reporter
	chromeos-base/modem-utilities
	chromeos-base/vboot_reference
	media-libs/fontconfig
	media-sound/alsa-utils
	sys-apps/coreboot-utils
	sys-apps/mosys
	sys-apps/net-tools
	sys-apps/pciutils
	sys-apps/usbutils
	X? ( x11-apps/setxkbmap )"

DEPEND=""

src_unpack() {
	cros-workon_src_unpack
	S+="/userfeedback"
}

src_install() {
	exeinto /usr/share/userfeedback/scripts
	doexe scripts/*

	insinto /usr/share/userfeedback/etc
	doins etc/*

	# Install init scripts.
	if use systemd; then
		local units=("mosys-info.service" "firmware-version.service")
		systemd_dounit init/*.service
		for unit in "${units[@]}"; do
			systemd_enable_service system-services.target ${unit}
		done
	else
		insinto /etc/init
		doins init/*.conf
	fi
}