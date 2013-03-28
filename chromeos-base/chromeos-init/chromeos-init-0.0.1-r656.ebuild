# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="1edbfb369f7bb7981dab635f9bcb40cc93f9e6a2"
CROS_WORKON_TREE="946db750191b11e8d16e04ed8e90c73c36e90010"
CROS_WORKON_PROJECT="chromiumos/platform/init"
CROS_WORKON_LOCALNAME="init"

inherit cros-workon

DESCRIPTION="Upstart init scripts for Chromium OS"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="nfs"

DEPEND=""
# vpd for vpd-log.conf of upstart
# vboot_reference for crossystem
RDEPEND="chromeos-base/chromeos-disableecho
	!<chromeos-base/shill-0.0.1-r805
	chromeos-base/vboot_reference
	chromeos-base/vpd
	net-firewall/iptables[ipv6]
	sys-apps/chvt
	sys-apps/smartmontools
	sys-apps/upstart"

src_install() {
	into /	# We want /sbin, not /usr/sbin, etc.

	# Install Upstart configuration files.
	insinto /etc/init
	doins *.conf

	insinto /etc
	doins issue rsyslog.chromeos

	# Install various utility files
	dosbin killers
	dosbin date-proxy-watcher

	# Install startup/shutdown scripts.
	dosbin chromeos_startup chromeos_shutdown
	dosbin chromeos-boot-alert
	dosbin clobber-state
	dosbin clobber-log
	dosbin display_low_battery_alert

	# Install log cleaning script and run it daily.
	into /usr
	dosbin chromeos-cleanup-logs
	dosbin simple-rotate
	dosbin netfilter-common

	# Install lightup_screen
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
}
