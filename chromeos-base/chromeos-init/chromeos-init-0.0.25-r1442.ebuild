# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="cc59505062b46e930d6ca17d1424099038c90f05"
CROS_WORKON_TREE="f83dc9504eb2ac0ff96862c27e35e2de4228e83d"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="init"

inherit cros-workon platform user

DESCRIPTION="Upstart init scripts for Chromium OS"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="cros_embedded +encrypted_stateful frecon +udev"

# shunit2 should be a dependency only if USE=test, but cros_run_unit_test
# doesn't calculate dependencies when emerging packages.
DEPEND="chromeos-base/libchromeos
	dev-util/shunit2
"
# vboot_reference for crossystem
RDEPEND="${DEPEND}
	chromeos-base/bootstat
	!chromeos-base/chromeos-disableecho
	chromeos-base/tty
	chromeos-base/vboot_reference
	sys-apps/rootdev
	sys-apps/upstart
	sys-process/lsof
	virtual/chromeos-bootcomplete
	!cros_embedded? (
		chromeos-base/common-assets
		chromeos-base/swap-init
		media-gfx/ply-image
		sys-apps/chvt
		sys-apps/smartmontools
	)
	frecon? (
		sys-apps/frecon
	)
"

platform_pkg_test() {
	local tests=( periodic_scheduler_unittest killers_unittest )

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "./${test_bin}"
	done
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

	# Install static node tool.
	dosbin "${OUT}"/static_node_tool

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
		doins cgroups.conf
		doins dbus.conf failsafe-delay.conf failsafe.conf halt.conf
		doins log-rotate.conf
		doins pre-shutdown.conf pre-startup.conf pstore.conf reboot.conf
		doins syslog.conf system-services.conf
		doins uinput.conf

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

pkg_preinst() {
	# Add the syslog user
	enewuser syslog
	enewgroup syslog

	# Create debugfs-access user and group, which is needed by the
	# chromeos_startup script to mount /sys/kernel/debug.  This is needed
	# by bootstat and ureadahead.
	enewuser "debugfs-access"
	enewgroup "debugfs-access"
}
