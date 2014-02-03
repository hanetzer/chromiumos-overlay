# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="6fb619775c0dd4256143d015ccc3156baaeab0da"
CROS_WORKON_TREE="070600abaaf618b83e2a0a66baf7d0a6c21dd7bb"
CROS_WORKON_PROJECT="chromiumos/platform/crash-reporter"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-debug cros-workon udev

DESCRIPTION="Build chromeos crash handler"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="-asan -clang test"
REQUIRED_USE="asan? ( clang )"

LIBCHROME_VERS="180609"

# crash_sender uses sys-apps/findutils (for /usr/bin/find).
RDEPEND="chromeos-base/google-breakpad
	chromeos-base/libchrome:${LIBCHROME_VERS}[cros-debug=]
	chromeos-base/platform2
	chromeos-base/chromeos-ca-certificates
	dev-cpp/gflags
	dev-libs/libpcre
	test? ( dev-cpp/gtest )
	net-misc/curl
	sys-apps/findutils"
DEPEND="${RDEPEND}
	sys-devel/flex"

src_prepare() {
	cros-workon_src_prepare
}

src_configure() {
	clang-setup-env
	cros-workon_src_configure
}

src_compile() {
	cros-workon_src_compile
}

src_test() {
	# TODO(benchan): Enable unit tests for arm target once
	# crosbug.com/27127 is fixed.
	if use arm; then
		echo Skipping unit tests on arm platform
	else
		# TODO(mkrebs): The tests are not currently thread-safe, so
		# running them in the default parallel mode results in
		# failures.
		emake -j1 tests
	fi
}

src_install() {
	cros-workon_src_install

	into /
	dosbin "${OUT}"/crash_reporter
	dosbin crash_sender

	into /usr
	dobin "${OUT}"/list_proxies
	dobin "${OUT}"/warn_collector
	dosbin kernel_log_collector.sh

	insinto /etc
	doins crash_reporter_logs.conf

	udev_dorules 99-crash-reporter.rules
}
