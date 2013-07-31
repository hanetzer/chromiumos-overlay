# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="4c141cf11b744147d2788381c1443f101f8d3b8c"
CROS_WORKON_TREE="465970079c3ebdd468463d341ea4d7ae940422e4"
CROS_WORKON_PROJECT="chromiumos/platform/p2p"

inherit autotools cros-debug cros-workon

DESCRIPTION="Chrome OS P2P"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

LIBCHROME_VERS="180609"

RDEPEND="chromeos-base/libchrome:${LIBCHROME_VERS}[cros-debug=]
	dev-libs/glib
	net-dns/avahi"

DEPEND="test? ( dev-cpp/gmock )
	test? ( dev-cpp/gtest )
	${RDEPEND}"

src_prepare() {
	eautoreconf
}

src_configure() {
	econf $(use_enable test tests)
}
