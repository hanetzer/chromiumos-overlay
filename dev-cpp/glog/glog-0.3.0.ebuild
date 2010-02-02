# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="2"

inherit libtool

DESCRIPTION="Google's C++ logging library."
HOMEPAGE="http://code.google.com/p/google-glog/"
SRC_URI="http://google-glog.googlecode.com/files/${P}.tar.gz"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm"
IUSE="gflags"

DEPEND="gflags? ( dev-cpp/gflags )"
RDEPEND="${DEPEND}"

src_configure() {
	if use gflags ; then
		if tc-is-cross-compiler ; then
			# The test for gflags fails when cross compiling.
			export ac_cv_lib_gflags_main=yes
		fi
	fi

	# The glog configure takes an optional "--with-gflags=GFLAGS_DIR".
	# Ideally we could use pkg-config, but gflags doesn't create one yet.
	econf $(use_with gflags gflags "${ROOT}usr") || die "econf failed."
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
}
