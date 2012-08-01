# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="1e1ffc310da40cf98b76dbdb825708f7527c2e69"
CROS_WORKON_TREE="725efe3721d8de2e77e1bd051ec0fd4af3c9eea6"

EAPI=2
CROS_WORKON_PROJECT="chromiumos/platform/init"

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
	chromeos-base/vboot_reference
	chromeos-base/vpd
	net-firewall/iptables[ipv6]
	sys-apps/smartmontools
	sys-apps/upstart"

CROS_WORKON_LOCALNAME="init"

src_install() {
	into /	# We want /sbin, not /usr/sbin, etc.

	# Install Upstart configuration files.
	dodir /etc/init
	install --owner=root --group=root --mode=0644 \
		"${S}"/*.conf "${D}/etc/init/"

	dodir /etc
	install --owner=root --group=root --mode=0644 \
		"${S}/issue" "${D}/etc/"

	# Install various utility files
	dosbin "${S}/killers"
	dosbin "${S}/send_boot_metrics"

	# Install startup/shutdown scripts.
	dosbin "${S}/chromeos_startup" "${S}/chromeos_shutdown"
	dosbin "${S}/chromeos-boot-alert"
	dosbin "${S}/clobber-state"
	dosbin "${S}/clobber-log"

	# Install log cleaning script and run it daily.
	into /usr
	dosbin "${S}/chromeos-cleanup-logs"

	# Install lightup_screen
	into /usr
	dosbin "${S}/lightup_screen"

	# Install rsyslogd's configuration file.
	insinto /etc
	doins rsyslog.chromeos || die

	# Some daemons and utilities access the mounts through /etc/mtab.
	dosym /proc/mounts /etc/mtab || die

	if use nfs; then
		# With USE=nfs we remove the iptables rules to allow mounting
		# of the root device.
		rm "${D}/etc/init/iptables.conf" || die
		rm "${D}/etc/init/ip6tables.conf" || die
		# If nfs mounted use a tmpfs stateful partition like factory
		sed -i 's/ext4/tmpfs/' "${D}/sbin/chromeos_startup" || die
	fi
}
