# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="82d3d8de75c9b35ca78a54ca103c5f52c53aa849"
CROS_WORKON_TREE="c4d443120365db4bb01cc8c9def6f8ab8d7b70a2"
CROS_WORKON_PROJECT="chromiumos/platform/init"
CROS_WORKON_LOCALNAME="init"

inherit cros-workon

DESCRIPTION="Upstart init scripts for Chromium OS"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"

# NOTE: vt can only be turned off for embedded currently.
IUSE="cros_embedded nfs vt"

DEPEND=""
# vpd for vpd-log.conf of upstart
# vboot_reference for crossystem
RDEPEND="
	chromeos-base/crash-reporter
	!<chromeos-base/shill-0.0.1-r805
	chromeos-base/vboot_reference
	net-firewall/iptables[ipv6]
	sys-apps/rootdev
	sys-apps/upstart
	sys-process/lsof
	!cros_embedded? (
		chromeos-base/chromeos-disableecho
		chromeos-base/vpd
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
		doins install-completed.conf ip6tables.conf iptables.conf
		doins pre-shutdown.conf pstore.conf reboot.conf shill.conf
		doins shill_respawn.conf syslog.conf system-services.conf tlsdated.conf
		doins update-engine.conf wpasupplicant.conf

		use vt && doins tty2.conf

		# TODO(petkov): Consider a separate USE flag for mounting encrypted
		# vs. unencrypted /var and /home/chronos (crbug.com/242840).
		insinto /usr/share/cros
		doins embedded-init/startup_utils.sh
	else
		insinto /etc/init
		doins *.conf

		dosbin chromeos-boot-alert
		dosbin display_low_battery_alert

		insinto /usr/share/cros
		doins startup_utils.sh

		into /usr
		dosbin lightup_screen

		if use nfs; then
			# With USE=nfs we remove the iptables rules to allow mounting
			# of the root device.
			rm "${D}/etc/init/iptables.conf" || die
			rm "${D}/etc/init/ip6tables.conf" || die
			# If nfs mounted use a tmpfs stateful partition like factory
			sed -i 's/ext4/tmpfs/; s/,commit=600//' \
				"${D}/sbin/chromeos_startup" || die
		fi
	fi
}
