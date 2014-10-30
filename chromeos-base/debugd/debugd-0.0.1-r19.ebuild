# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="61ae6bfd4ea8da313a6b861e425ea09a85d16f19"
CROS_WORKON_TREE="64cd11270cd2f7e21e020b52092fbeb355ae8b04"
CROS_WORKON_INCREMENTAL_BUILD="1"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_DESTDIR="${S}/platform2"

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
	!<chromeos-base/platform2-0.0.15
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
