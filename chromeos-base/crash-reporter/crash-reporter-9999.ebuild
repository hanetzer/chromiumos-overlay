# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit toolchain-funcs

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

src_unpack() {
	local platform="${CHROMEOS_ROOT}/src/platform"

	elog "Using platform: $platform"
	mkdir -p "${S}/crash"
	cp -a "${platform}"/crash/* "${S}/crash" || die
} 

src_compile() {
	tc-export CXX PKG_CONFIG
	pushd "crash"
	emake crash_reporter || die "crash_reporter compile failed."
	popd
}

src_test() {
	tc-export CXX PKG_CONFIG
	pushd "crash"
	emake tests || die "could not build tests"
	if ! use x86; then
	        echo Skipping unit tests on non-x86 platform
	else
	        for test in ./*_test; do
		        "${test}" ${GTEST_ARGS} || die "${test} failed"
		done
	fi
	popd
}

src_install() {
	into /
	dosbin "${S}/crash/crash_reporter" || die
	dosbin "${S}/crash/crash_sender" || die
	exeinto /etc/cron.hourly || die
	doexe "${S}/crash/crash_sender.hourly" || die
}
