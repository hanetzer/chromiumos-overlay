# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT="72cccedf6f1f3b67aa85cc1e3f16a5e1c6ebec23"
CROS_WORKON_TREE="6aac938e8937d8ec98cd7e4d6c61bf929a40d33a"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_USE_VCSID=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_DESTDIR="${S}/platform2"

PLATFORM_SUBDIR="crash-reporter"

inherit cros-workon platform udev

DESCRIPTION="Crash reporting service that uploads crash reports with debug
information"
HOMEPAGE="http://dev.chromium.org/chromium-os/platform"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="cros_embedded -cros_host test"
REQUIRE_USE="!cros_host"

RDEPEND="
	chromeos-base/chromeos-ca-certificates
	chromeos-base/google-breakpad
	chromeos-base/libchromeos
	chromeos-base/metrics
	!<chromeos-base/platform2-0.0.5
	dev-cpp/gflags
	>=dev-libs/glib-2.30
	dev-libs/libpcre
	net-misc/curl
"
DEPEND="
	${RDEPEND}
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
	dobin "${OUT}"/list_proxies
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
	# TODO(mkrebs): The tests are not currently thread-safe, so
	# running them in the default parallel mode results in
	# failures.
	local tests=(
		chrome_collector_test
		crash_collector_test
		kernel_collector_test
		udev_collector_test
		unclean_shutdown_collector_test
		user_collector_test
	)

	# TODO: QEMU mishandles readlink(/proc/self/exe) symlink, so filter out
	# tests that rely on that.  Once we update to a newer version though, we
	# can drop this filter.
	# https://lists.nongnu.org/archive/html/qemu-devel/2014-08/msg01210.html
	local qemu_gtest_filter="-UserCollectorTest.GetExecutableBaseNameFromPid"

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}" "" "" "${qemu_gtest_filter}"
	done
}
