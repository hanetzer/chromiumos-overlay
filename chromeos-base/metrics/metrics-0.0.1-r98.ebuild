# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="e67ac5f5ac688bf6b3c84eed9ddcf2c0f02f0f70"
CROS_WORKON_TREE="e428fd3220e2c88565ba39d8fdc3997462648815"
CROS_WORKON_PROJECT="chromiumos/platform/metrics"

inherit cros-debug cros-workon

DESCRIPTION="Chrome OS Metrics Collection Utilities"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

LIBCHROME_VERS="180609"

RDEPEND="chromeos-base/libchrome:${LIBCHROME_VERS}[cros-debug=]
	chromeos-base/libchromeos
	dev-cpp/gflags
	dev-libs/dbus-glib
	>=dev-libs/glib-2.0
	sys-apps/dbus
	sys-apps/rootdev
	"
DEPEND="${RDEPEND}
	chromeos-base/system_api
	dev-cpp/gmock
	dev-cpp/gtest
	"

src_configure() {
	cros-workon_src_configure
}

src_compile() {
	tc-export CXX AR PKG_CONFIG
	cros-debug-add-NDEBUG
	export BASE_VER=${LIBCHROME_VERS}
	emake
}

src_test() {
	tc-export CXX AR PKG_CONFIG
	cros-debug-add-NDEBUG
	emake tests
	if ! use x86 && ! use amd64 ; then
		elog "Skipping unit tests on non-x86 platform"
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
	dobin metrics_{client,daemon} syslog_parser.sh

	dolib.so libmetrics.so

	insinto /usr/include/metrics
	doins c_metrics_library.h metrics_library{,_mock}.h timer{,_mock}.h
}
