# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="2"

inherit eutils libtool

DESCRIPTION="Google's C++ logging library."
HOMEPAGE="http://code.google.com/p/google-glog/"
SRC_URI="http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/${P}.tar.gz"
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="gflags"

RDEPEND="gflags? ( dev-cpp/gflags )"

DEPEND="${RDEPEND}
	test? (
		dev-cpp/gmock
		dev-cpp/gtest
	)"

src_configure() {
	if use gflags ; then
		if tc-is-cross-compiler ; then
			# The test for gflags fails when cross compiling.
			export ac_cv_lib_gflags_main=yes
		fi
	fi

	# Suppress building tests when test is not enabled.
	use test || export ac_cv_prog_GTEST_CONFIG=no

	# Fix the library and header paths:
	# http://code.google.com/p/chromium-os/issues/detail?id=19901
	epatch "${FILESDIR}"/glog-libdir-paths.patch

	# The glog configure takes an optional "--with-gflags=GFLAGS_DIR".
	# Ideally we could use pkg-config, but gflags doesn't create one yet.
	econf $(use_with gflags gflags "${ROOT}usr") || die "econf failed."
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
}
