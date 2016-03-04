# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT="e09454425f4d1b5d142e3519c328979726a6afd5"
CROS_WORKON_TREE="94f38d8c88dc0e8f6d0e3b3276cf7b79f0863347"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_USE_VCSID=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="crash-reporter"

inherit cros-workon platform udev

DESCRIPTION="Crash reporting service that uploads crash reports with debug
information"
HOMEPAGE="http://dev.chromium.org/chromium-os/platform"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="arc cros_embedded -cros_host test"
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
	dobin "${OUT}"/warn_collector
	dosbin kernel_log_collector.sh

	insinto /etc/init
	doins init/crash-reporter.conf init/crash-sender.conf
	use cros_embedded || doins init/warn-collector.conf

	insinto /etc
	doins crash_reporter_logs.conf

	udev_dorules 99-crash-reporter.rules
}

platform_pkg_test() {
	platform_test "run" "${OUT}/crash_reporter_test"
}
