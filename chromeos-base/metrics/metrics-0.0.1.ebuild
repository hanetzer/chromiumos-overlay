# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit toolchain-funcs

DESCRIPTION="Chrome OS Metrics Collection Utilities"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE=""

# TODO(petkov): Remove dependences on metrics_collection and metrics_daemon
# and the empty ebuilds once the build dust settles.
RDEPEND="chromeos-base/chromeos-metrics_collection
	chromeos-base/chromeos-metrics_daemon
	chromeos-base/libchrome
	>=dev-libs/glib-2.0
	dev-libs/dbus-glib
	sys-apps/dbus"

DEPEND="dev-cpp/gflags
	dev-cpp/gtest
	${RDEPEND}"

src_unpack() {
	local metrics="${CHROMEOS_ROOT}/src/platform/metrics"
	elog "Using metrics sources: $metrics"
	cp -ar "${metrics}" "${S}" || die
}

src_compile() {
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
	dodir /usr/bin
	dodir /usr/include
	dodir /usr/lib
	dodir /usr/sbin
	emake DESTDIR="${D}" install || die "metrics install failed."
	chmod 0555 "${D}/usr/sbin/omaha_tracker.sh"
}
