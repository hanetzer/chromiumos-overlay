# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="a5eeac71a63ca408b5074885a7b1d4003fef6c74"
CROS_WORKON_TREE="8baa80976fc32d98c3ef5ab5de3b7d33685e10ad"

EAPI="4"
CROS_WORKON_PROJECT="chromiumos/platform/crash-reporter"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-debug cros-workon

DESCRIPTION="Build chromeos crash handler"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="test"

LIBCHROME_VERS="125070"

# crash_sender uses sys-apps/findutils (for /usr/bin/find).
RDEPEND="chromeos-base/google-breakpad
         chromeos-base/libchrome:${LIBCHROME_VERS}[cros-debug=]
         chromeos-base/libchromeos
         chromeos-base/metrics
         chromeos-base/chromeos-ca-certificates
         dev-cpp/gflags
         dev-libs/libpcre
         test? ( dev-cpp/gtest )
         net-misc/curl
         sys-apps/findutils"
DEPEND="${RDEPEND}"

src_prepare() {
	cros-workon_src_prepare
}

src_configure() {
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
	into /
	dosbin "${OUT}"/crash_reporter
	dosbin crash_sender
	into /usr
	dobin "${OUT}"/list_proxies
	insinto /etc
	doins crash_reporter_logs.conf

	insinto /lib/udev/rules.d
	doins 99-crash-reporter.rules
}
