# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="8c8b11d8e359b11e36f4be80bd52ac12688ce24c"
CROS_WORKON_TREE="c7a20f72386199459cac5b15a4e37d70cfac5a54"
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

src_configure() {
	cros-workon_src_configure
        tc-export CC CXX AR PKG_CONFIG
}

src_compile() {
	emake
}

src_test() {
	emake tests
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
	dosbin bootstat
	dosbin bootstat_get_last
	dobin bootstat_summary

	into /usr
	dolib.a libbootstat.a

	insinto /usr/include/metrics
	doins bootstat.h
}
