# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="9260c449ea33dcdc122b2d3472d4c390d45fbfd6"

inherit cros-debug cros-workon flag-o-matic

DESCRIPTION="Chrome OS Metrics Collection Utilities"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86 arm"
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
	cros-debug-add-NDEBUG
	emake || die "metrics compile failed."
}

src_test() {
	tc-export CXX AR PKG_CONFIG
	cros-debug-add-NDEBUG
	emake tests || die "could not build tests"
	if ! use x86; then
		echo Skipping unit tests on non-x86 platform
	else
		for test in ./*_test; do
			# Always test the shared object we just built by
			# adding . to the library path.
			LD_LIBRARY_PATH=.:${LD_LIBRARY_PATH} \
			"${test}" ${GTEST_ARGS} || die "${test} failed"
		done
	fi
}

src_install() {
	dobin hardware_class || die
	dobin metrics_client || die
	dobin metrics_daemon || die
	dobin syslog_parser.sh || die
	dolib.a libmetrics.a || die
	dolib.so libmetrics.so || die

	insinto /usr/include/metrics
	doins c_metrics_library.h || die
	doins metrics_library.h || die
	doins metrics_library_mock.h || die
}
