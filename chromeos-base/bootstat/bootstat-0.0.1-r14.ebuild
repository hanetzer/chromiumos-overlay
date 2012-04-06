# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="ebfb21981f7309379d072140a775e4b3b3e2d05b"
CROS_WORKON_TREE="b1d33fcdcea52db5eb53f8edcf68bc28f4b7cdf1"

EAPI=2
CROS_WORKON_PROJECT="chromiumos/platform/bootstat"
inherit cros-workon

DESCRIPTION="Chrome OS Boot Time Statistics Utilities"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE=""

RDEPEND=""

DEPEND="dev-cpp/gtest"

src_compile() {
	tc-export CC CXX AR PKG_CONFIG
	emake || die "bootstat compile failed."
}

src_test() {
	tc-export CC CXX AR PKG_CONFIG
	emake tests || die "could not build tests"
	if ! use x86 && ! use amd64 ; then
		echo Skipping unit tests on non-x86 platform
	else
		for test in ./*_test; do
			"${test}" ${GTEST_ARGS} || die "${test} failed"
		done
	fi
}

src_install() {
	into /
	dosbin bootstat || die
	dosbin bootstat_get_last || die

	into /usr
	dolib.a libbootstat.a || die

	insinto /usr/include/metrics
	doins bootstat.h || die
}
