# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="c2815926173253eb43c13d02e79c9e514dac4926"
CROS_WORKON_TREE="22f3898b8198c18e859a6931d7e2c3e69c763c87"
CROS_WORKON_INCREMENTAL_BUILD="1"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="debugd"

inherit cros-workon platform user

DESCRIPTION="Chrome OS debugging service"
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD-Google"
SLOT="0"
IUSE="cellular test wimax"
KEYWORDS="*"

RDEPEND="
	chromeos-base/chromeos-login
	chromeos-base/chromeos-minijail
	chromeos-base/chromeos-ssh-testkeys
	chromeos-base/chromeos-sshd-init
	chromeos-base/libchromeos
	chromeos-base/shill
	chromeos-base/system_api
	chromeos-base/vboot_reference
	dev-libs/dbus-c++
	dev-libs/glib
	dev-libs/libpcre
	dev-libs/protobuf
	net-libs/libpcap
	sys-apps/memtester
	sys-apps/rootdev
	sys-apps/smartmontools
	cellular? ( virtual/modemmanager )
"
DEPEND="${RDEPEND}
	chromeos-base/chromeos-login
	chromeos-base/debugd-client
	chromeos-base/shill
	sys-apps/dbus
	virtual/modemmanager"

pkg_preinst() {
	enewuser "debugd"
	enewgroup "debugd"
	enewuser "debugd-logs"
	enewgroup "debugd-logs"

	enewgroup "daemon-store"
	enewgroup "logs-access"
}

src_install() {
	into /
	dosbin "${OUT}"/debugd
	dodir /debugd

	exeinto /usr/libexec/debugd/helpers
	doexe "${OUT}"/capture_packets
	doexe "${OUT}"/dev_features_chrome_remote_debugging
	doexe "${OUT}"/dev_features_password
	doexe "${OUT}"/dev_features_rootfs_verification
	doexe "${OUT}"/dev_features_ssh
	doexe "${OUT}"/dev_features_usb_boot
	doexe "${OUT}"/icmp
	doexe "${OUT}"/netif
	doexe "${OUT}"/network_status
	use cellular && doexe "${OUT}"/modem_status
	use wimax && doexe "${OUT}"/wimax_status

	doexe src/helpers/{capture_utility,minijail-setuid-hack,systrace}.sh
	use cellular && doexe src/helpers/send_at_command.sh

	# Install DBus configuration.
	insinto /etc/dbus-1/system.d
	doins share/org.chromium.debugd.conf

	insinto /etc/init
	doins share/{debugd,trace_marker-test}.conf

	insinto /etc/perf_commands
	doins -r share/perf_commands/*
}

platform_pkg_test() {
	pushd "${S}/src" >/dev/null
	platform_test "run" "${OUT}/debugd_testrunner"
	./helpers/capture_utility_test.sh || die
	popd >/dev/null
}
