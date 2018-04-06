# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="adf4844e956e653e0ec2b0e7baeb0faf0727d2e7"
CROS_WORKON_TREE=("61b4b0c05e003fddaa705031945fece7f560c7d7" "b8bd72d7a0d6cf97bc7777232e247d93cc4bf038")
CROS_WORKON_INCREMENTAL_BUILD="1"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk debugd"

PLATFORM_SUBDIR="debugd"

inherit cros-workon platform user

DESCRIPTION="Chrome OS debugging service"
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="cellular iwlwifi_dump wimax"

COMMON_DEPEND="
	chromeos-base/chromeos-login
	chromeos-base/minijail
	chromeos-base/chromeos-ssh-testkeys
	chromeos-base/chromeos-sshd-init
	chromeos-base/libbrillo
	chromeos-base/shill-client
	chromeos-base/system_api
	chromeos-base/vboot_reference
	!chromeos-base/workarounds
	dev-libs/dbus-c++
	dev-libs/libpcre
	dev-libs/protobuf
	net-libs/libpcap
	net-wireless/iw
	sys-apps/iproute2
	sys-apps/memtester
	sys-apps/rootdev
	sys-apps/smartmontools
	cellular? ( virtual/modemmanager )
"
RDEPEND="${COMMON_DEPEND}
	iwlwifi_dump? ( chromeos-base/intel-wifi-fw-dump )
"
DEPEND="${COMMON_DEPEND}
	chromeos-base/chromeos-login
	chromeos-base/debugd-client
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
	dobin "${OUT}"/generate_logs

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
