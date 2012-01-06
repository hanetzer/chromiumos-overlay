# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="3d70f8061c951181629a22d5f4cb1cacb21d2e82"
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
         chromeos-base/libchrome
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
	if ! use x86; then
	        echo Skipping unit tests on non-x86 platform
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
	exeinto /etc/cron.hourly || die
	doexe "crash_sender.hourly" || die
	insinto /etc || die
	doins "crash_reporter_logs.conf" || die
}
