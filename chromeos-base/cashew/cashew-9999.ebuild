# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_PROJECT="chromiumos/platform/cashew"

inherit cros-debug cros-workon autotools

DESCRIPTION="Chromium OS network usage tracking daemon"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE="test"

LIBCHROME_VERS="125070"

RDEPEND="chromeos-base/flimflam
	chromeos-base/libchrome:${LIBCHROME_VERS}[cros-debug=]
	chromeos-base/metrics
	dev-cpp/gflags
	>=dev-cpp/glog-0.3.1
	dev-libs/dbus-c++
	dev-libs/glib
	net-misc/curl"

DEPEND="${RDEPEND}
	test? (
		dev-cpp/gmock
		dev-cpp/gtest
	)"

src_prepare() {
	eautoreconf
}

src_configure() {
	# set NDEBUG (or not) based on value of cros-debug USE flag
	cros-debug-add-NDEBUG
	econf --with-libbase-ver=${LIBCHROME_VERS}
}

src_compile() {
	emake clean-generic
	emake
}

src_test() {
	# build and run unit tests
	emake check
	if use amd64 || use x86 ; then
		src/cashew_unittest ${GTEST_ARGS} \
			|| die "unit tests (with GTEST_ARGS = ${GTEST_ARGS}) failed!"
	else
		# don't try to run cross-compiled non-x86 unit test binaries in our x86
		# host environment
		einfo =====================================
		einfo Skipping tests on non-x86 platform...
		einfo =====================================
	fi
}
