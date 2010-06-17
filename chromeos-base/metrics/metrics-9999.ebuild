# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit cros-workon flag-o-matic

DESCRIPTION="Chrome OS Metrics Collection Utilities"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm"
IUSE="debug"

RDEPEND="chromeos-base/libchrome
	dev-cpp/gflags
	dev-libs/dbus-glib
	>=dev-libs/glib-2.0
	sys-apps/dbus
	"

DEPEND="${RDEPEND}
	dev-cpp/gmock
	dev-cpp/gtest
	"

src_compile() {
	use debug || append-flags -DNDEBUG
	tc-export CXX AR PKG_CONFIG
	emake || die "metrics compile failed."
}

src_test() {
	tc-export CXX AR PKG_CONFIG
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
	dobin "${S}/generate_logs"
	dobin "${S}/hardware_class"
	dobin "${S}/metrics_client"
	dobin "${S}/metrics_daemon"
	dobin "${S}/syslog_parser.sh"
	dolib.a "${S}/libmetrics.a"
	dolib.so "${S}/libmetrics.so"
	dosbin "${S}/omaha_tracker.sh"

	insinto "/usr/include/metrics"
	doins "${S}/c_metrics_library.h"
	doins "${S}/metrics_library.h"
	doins "${S}/metrics_library_mock.h"
}
