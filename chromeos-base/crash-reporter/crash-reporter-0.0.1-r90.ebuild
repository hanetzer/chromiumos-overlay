# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="cf20766ad3aa8211716e47a5fd61bfb55a132790"
CROS_WORKON_TREE="1868cec09a6e5083a860bf49eb28b631d90e89bf"

EAPI=2
CROS_WORKON_PROJECT="chromiumos/platform/crash-reporter"

inherit cros-debug cros-workon toolchain-funcs

DESCRIPTION="Build chromeos crash handler"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="test"

# crash_sender uses sys-apps/findutils (for /usr/bin/find).
RDEPEND="chromeos-base/google-breakpad
         chromeos-base/libchrome:85268[cros-debug=]
         chromeos-base/libchromeos
         chromeos-base/metrics
         chromeos-base/chromeos-ca-certificates
         dev-cpp/gflags
         dev-libs/libpcre
         test? ( dev-cpp/gtest )
         net-misc/curl
         sys-apps/findutils"
DEPEND="${RDEPEND}"

src_compile() {
	tc-export CXX PKG_CONFIG
	cros-debug-add-NDEBUG
	emake || die "crash_reporter compile failed."
}

src_test() {
	tc-export CXX PKG_CONFIG
	cros-debug-add-NDEBUG
	emake tests || die "could not build tests"
	# TODO(benchan): Enable unit tests for arm target once
	# crosbug.com/27127 is fixed.
	if use arm; then
	        echo Skipping unit tests on arm platform
	else
	        for test in ./*_test; do
		        "${test}" ${GTEST_ARGS} || die "${test} failed"
		done
	fi
}

src_install() {
	into / || die
	dosbin "crash_reporter" || die
	dosbin "crash_sender" || die
	into /usr || die
	dobin "list_proxies" || die
	insinto /etc || die
	doins "crash_reporter_logs.conf" || die
}
