# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="4b0f9328e20a628bfe8eee8736ef82b0e3fd4d0e"
CROS_WORKON_TREE="154cfa9c45fd2cb3eede69c7f859980ec3695e38"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_INCREMENTAL_BUILD=1

PLATFORM_SUBDIR="init"

inherit cros-workon platform user

DESCRIPTION="Upstart init scripts for Chromium OS"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="
	cros_embedded +encrypted_stateful frecon
	kernel-3_8 kernel-3_10 kernel-3_14 kernel-3_18 +midi
	-s3halt +syslog systemd +udev vtconsole"

# shunit2 should be a dependency only if USE=test, but cros_run_unit_test
# doesn't calculate dependencies when emerging packages.
DEPEND="chromeos-base/libbrillo
	dev-util/shunit2
"
# vboot_reference for crossystem
RDEPEND="${DEPEND}
	app-arch/tar
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

src_test() {
	if use x86 || use amd64; then
		cros-workon_src_test
	else
		einfo "Skipping unit tests on non-x86 platform"
	fi
}

src_install() {
	# Install helper to run periodic tasks.
	dobin periodic_scheduler

	if use syslog; then
		# Install log cleaning script and run it daily.
		dosbin chromeos-cleanup-logs
		dosbin simple-rotate

		insinto /etc
		doins rsyslog.chromeos
	fi

	insinto /usr/share/cros
	doins *_utils.sh

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

	insinto /etc/init

	if use cros_embedded; then
		doins startup.conf
		doins embedded-init/boot-services.conf

		doins report-boot-complete.conf
		doins failsafe-delay.conf failsafe.conf
		doins pre-shutdown.conf pre-startup.conf pstore.conf reboot.conf
		doins system-services.conf
		doins uinput.conf
		doins static-nodes.conf

		if use syslog; then
			doins log-rotate.conf syslog.conf
		fi
		if use !systemd; then
			doins cgroups.conf
			doins dbus.conf
			use udev && doins udev.conf udev-trigger.conf udev-trigger-early.conf
		fi
	else
		doins *.conf

		dosbin display_low_battery_alert
	fi
	if use midi; then
		if use kernel-3_8 || use kernel-3_10 || use kernel-3_14 || use kernel-3_18; then
			doins workaround-init/midi-workaround.conf
		fi
	fi

	if use s3halt; then
		newins halt/s3halt.conf halt.conf
	else
		doins halt/halt.conf
	fi

	use vtconsole && doins vtconsole/*.conf

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
