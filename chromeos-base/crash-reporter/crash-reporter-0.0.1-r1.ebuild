# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit cros-workon toolchain-funcs

DESCRIPTION="Build chromeos crash handler"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="x86 arm"
IUSE="test"

RDEPEND="chromeos-base/crash-dumper
         chromeos-base/libchrome
         chromeos-base/metrics
         dev-cpp/gflags
         test? ( dev-cpp/gtest )"
DEPEND="${RDEPEND}"

src_compile() {
	tc-export CXX PKG_CONFIG
	emake crash_reporter || die "crash_reporter compile failed."
}

src_test() {
	tc-export CXX PKG_CONFIG
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
	into /
	dosbin "crash_reporter" || die
	dosbin "crash_sender" || die
	exeinto /etc/cron.hourly || die
	doexe "crash_sender.hourly" || die
}
