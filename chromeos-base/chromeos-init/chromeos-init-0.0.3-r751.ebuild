# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="3c70691f365b39c6ba4229adede50c118639e13f"
CROS_WORKON_TREE="5bba1caa47104151518f043de3cabfa83cb63dd2"
CROS_WORKON_PROJECT="chromiumos/platform/init"
CROS_WORKON_LOCALNAME="init"

inherit cros-workon

DESCRIPTION="Upstart init scripts for Chromium OS"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"

# NOTE: vt can only be turned off for embedded currently.
IUSE="cros_embedded +encrypted_stateful vt"

DEPEND=""
# vpd for vpd-log.conf of upstart
# vboot_reference for crossystem
RDEPEND="
	chromeos-base/bootstat
	!<chromeos-base/shill-0.0.1-r805
	chromeos-base/vboot_reference
	sys-apps/rootdev
	sys-apps/upstart
	sys-process/lsof
	!cros_embedded? (
		chromeos-base/chromeos-assets
		chromeos-base/chromeos-disableecho
		chromeos-base/vpd
		media-gfx/ply-image
		sys-apps/chvt
		sys-apps/smartmontools
	)
"

src_install() {
	# Install log cleaning script and run it daily.
	dosbin chromeos-cleanup-logs
	dosbin simple-rotate
	dosbin netfilter-common

	insinto /etc
	doins issue rsyslog.chromeos

	insinto /usr/share/cros
	doins factory_utils.sh

	into /	# We want /sbin, not /usr/sbin, etc.

	# Install various utility files.
	dosbin killers

	# Install startup/shutdown scripts.
	dosbin chromeos_startup chromeos_shutdown
	dosbin clobber-state
	dosbin clobber-log

	if use cros_embedded; then
		insinto /etc/init
		doins startup.conf
		doins embedded-init/boot-services.conf
		doins embedded-init/login-prompt-visible.conf

		doins boot-complete.conf cgroups.conf crash-reporter.conf cron-lite.conf
		doins dbus.conf failsafe-delay.conf failsafe.conf halt.conf
		doins install-completed.conf
		doins pre-shutdown.conf pstore.conf reboot.conf shill.conf
		doins shill_respawn.conf syslog.conf system-services.conf tlsdated.conf
		doins update-engine.conf wpasupplicant.conf

		use vt && doins tty2.conf
	else
		insinto /etc/init
		doins *.conf

		dosbin chromeos-boot-alert
		dosbin display_low_battery_alert

		into /usr
		dosbin lightup_screen

	fi

	insinto /usr/share/cros
	doins $(usex encrypted_stateful encrypted_stateful \
		unencrypted_stateful)/startup_utils.sh
}
