# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT="104990ff72eafb84511a3c8f35190fbbce8ff7b3"
CROS_WORKON_TREE="d344ad877178d370f4f342db21a6851284d385ef"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_USE_VCSID=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="crash-reporter"

inherit cros-workon platform systemd udev

DESCRIPTION="Crash reporting service that uploads crash reports with debug
information"
HOMEPAGE="http://dev.chromium.org/chromium-os/platform"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="arc cros_embedded -cros_host systemd test"
REQUIRED_USE="!cros_host"

RDEPEND="
	chromeos-base/chromeos-ca-certificates
	chromeos-base/google-breakpad
	chromeos-base/libbrillo
	chromeos-base/metrics
	dev-libs/libpcre
	net-misc/curl
"
DEPEND="
	${RDEPEND}
	chromeos-base/debugd-client
	chromeos-base/session_manager-client
	chromeos-base/system_api
	dev-cpp/gtest
	test? (
		dev-cpp/gmock
	)
	sys-devel/flex
"

src_install() {
	into /
	dosbin "${OUT}"/crash_reporter
	dosbin crash_sender

	into /usr
	use cros_embedded || dobin "${OUT}"/list_proxies
	use cros_embedded || dobin "${OUT}"/warn_collector
	dosbin kernel_log_collector.sh

	if use systemd; then
		systemd_dounit init/crash-reporter.service
		systemd_enable_service multi-user.target crash-reporter.service
		systemd_dounit init/crash-sender.service
		systemd_dounit init/crash-sender.timer
		systemd_enable_service timers.target crash-sender.timer

		# warn_collector does not work on systemd-enabled systems
		use cros_embedded || die "Warn-collector does not work with systemd"
	else
		insinto /etc/init
		doins init/crash-reporter.conf init/crash-sender.conf
		use cros_embedded || doins init/warn-collector.conf
	fi

	insinto /etc
	doins crash_reporter_logs.conf

	udev_dorules 99-crash-reporter.rules
}

platform_pkg_test() {
	platform_test "run" "${OUT}/crash_reporter_test"
}
