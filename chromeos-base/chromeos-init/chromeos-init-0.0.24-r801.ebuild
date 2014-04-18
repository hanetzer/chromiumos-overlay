# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="4ef552b3020513906f1a2ec06d690dab61296c4a"
CROS_WORKON_TREE="20ac5d4cdd5e3503bb90165a6044621d25af97d8"
CROS_WORKON_PROJECT="chromiumos/platform/init"
CROS_WORKON_LOCALNAME="init"

inherit cros-workon user

DESCRIPTION="Upstart init scripts for Chromium OS"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="cros_embedded +encrypted_stateful +udev"

DEPEND=""
# vboot_reference for crossystem
RDEPEND="
	chromeos-base/bootstat
	chromeos-base/vboot_reference
	sys-apps/rootdev
	sys-apps/upstart
	sys-process/lsof
	virtual/chromeos-bootcomplete
	!cros_embedded? (
		chromeos-base/chromeos-assets
		chromeos-base/chromeos-disableecho
		chromeos-base/swap-init
		media-gfx/ply-image
		sys-apps/chvt
		sys-apps/smartmontools
	)
"

pkg_preinst() {
	# Add the syslog user
	enewuser syslog
	enewgroup syslog
}

src_install() {
	# Install helper to run periodic tasks.
	dobin periodic_scheduler

	# Install log cleaning script and run it daily.
	dosbin chromeos-cleanup-logs
	dosbin simple-rotate

	insinto /etc
	doins rsyslog.chromeos

	insinto /usr/share/cros
	doins factory_utils.sh

	into /	# We want /sbin, not /usr/sbin, etc.

	# Install various utility files.
	dosbin killers

	# Install startup/shutdown scripts.
	dosbin chromeos_startup chromeos_shutdown
	dosbin clobber-state
	dosbin clobber-log
	dosbin chromeos-boot-alert


	if use cros_embedded; then
		insinto /etc/init
		doins startup.conf
		doins embedded-init/boot-services.conf

		doins report-boot-complete.conf
		doins cgroups.conf crash-sender.conf
		doins dbus.conf failsafe-delay.conf failsafe.conf halt.conf
		doins log-rotate.conf
		doins pre-shutdown.conf pstore.conf reboot.conf
		doins syslog.conf system-services.conf

		use udev && doins udev.conf udev-trigger.conf udev-trigger-early.conf
	else
		insinto /etc/init
		doins *.conf

		dosbin display_low_battery_alert
	fi

	insinto /usr/share/cros
	doins $(usex encrypted_stateful encrypted_stateful \
		unencrypted_stateful)/startup_utils.sh
}
