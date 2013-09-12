# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="107e36f0f3ce38fd98d3ed49df4ce7589b8bd398"
CROS_WORKON_TREE="8c9030dba6630ee94273466f244a33b4f7f39212"
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
	chromeos-base/metrics
	dev-libs/glib
	net-dns/avahi"

DEPEND="test? ( dev-cpp/gmock )
	test? ( dev-cpp/gtest )
	${RDEPEND}"

src_prepare() {
	eautoreconf
}

src_configure() {
	cros-workon_src_configure $(use_enable test tests)
}

src_test() {
	# Needed for `cros_run_unit_tests`.
	cros-workon_src_test
}
