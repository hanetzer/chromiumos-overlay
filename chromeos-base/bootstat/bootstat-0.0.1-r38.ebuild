# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="90554d0ffcae219fab6f36cdc500cf1443e9b262"
CROS_WORKON_TREE="6020ca72de3a5b4c7c3f7afd49c165400493cba3"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_DESTDIR="${S}/platform2"

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

src_unpack() {
	cros-workon_src_unpack
	S+="/platform2/libchromeos/chromeos/bootstat"
}

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
