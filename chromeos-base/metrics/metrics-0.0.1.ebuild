# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit flag-o-matic toolchain-funcs

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

src_unpack() {
	local metrics="${CHROMEOS_ROOT}/src/platform/metrics"
	elog "Using metrics sources: $metrics"
	cp -ar "${metrics}" "${S}" || die
}

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
	dodir /usr/bin
	dodir /usr/include
	dodir /usr/lib
	dodir /usr/sbin
	emake DESTDIR="${D}" install || die "metrics install failed."
	chmod 0555 "${D}/usr/sbin/omaha_tracker.sh"
}
