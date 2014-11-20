# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="3f60f1621e39309ac0fbd1110eeaa600882fee94"
CROS_WORKON_TREE="8a76071e4dac35a725650bce7cb6e10b3bde4ef8"
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
	chromeos-base/chromeos-minijail
	chromeos-base/libchromeos
	chromeos-base/system_api
	dev-libs/dbus-c++
	dev-libs/glib
	dev-libs/libpcre
	net-libs/libpcap
	sys-apps/memtester
	sys-apps/smartmontools
	cellular? ( virtual/modemmanager )
"
DEPEND="${RDEPEND}
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
	doexe "${OUT}"/{capture_packets,icmp,netif,network_status}
	use cellular && doexe "${OUT}"/modem_status
	use wimax && doexe "${OUT}"/wimax_status

	doexe src/helpers/{minijail-setuid-hack,systrace,capture_utility}.sh
	use cellular && doexe src/helpers/send_at_command.sh

	insinto /etc/dbus-1/system.d
	doins share/org.chromium.debugd.conf

	insinto /etc/init
	doins share/{debugd,trace_marker-test}.conf

	insinto /etc/perf_commands
	doins share/perf_commands/{arm,celeron-2955u,core,unknown}.txt
}

platform_pkg_test() {
	pushd "${S}/src" >/dev/null
	platform_test "run" "${OUT}/debugd_testrunner"
	./helpers/capture_utility_test.sh || die
	popd >/dev/null
}
