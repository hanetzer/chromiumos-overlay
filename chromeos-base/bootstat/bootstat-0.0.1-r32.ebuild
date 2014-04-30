# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="46c9cb748c3819f56e46c32ef1ac852542cf1395"
CROS_WORKON_TREE="2743b949d7912c7705301d721a64e8bed7260b45"
CROS_WORKON_PROJECT="chromiumos/platform/bootstat"
inherit cros-workon

DESCRIPTION="Chrome OS Boot Time Statistics Utilities"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="-asan -clang"
REQUIRED_USE="asan? ( clang )"

RDEPEND="sys-apps/rootdev"
DEPEND="${RDEPEND}
	dev-cpp/gtest"

src_configure() {
	clang-setup-env
	cros-workon_src_configure
	tc-export CC CXX AR PKG_CONFIG
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
	dosbin bootstat_archive
	dosbin bootstat_get_last
	dobin bootstat_summary

	into /usr
	dolib.a libbootstat.a

	insinto /usr/include/metrics
	doins bootstat.h

	insinto /usr/$(get_libdir)/pkgconfig
	doins bootstat.pc
}
