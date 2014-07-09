# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="8c46d687f99599f27d24e2f0316c472476f16532"
CROS_WORKON_TREE="5d635934c7b5e7bd6d2c1e4d7baacb65c75c827c"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_DESTDIR="${S}"

inherit autotools cros-debug cros-workon user

DESCRIPTION="Chrome OS P2P"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="-asan -clang"
REQUIRED_USE="asan? ( clang )"

LIBCHROME_VERS="271506"

RDEPEND="chromeos-base/libchrome:${LIBCHROME_VERS}[cros-debug=]
	chromeos-base/metrics
	dev-libs/glib
	net-dns/avahi-daemon
	net-firewall/iptables"

DEPEND="test? ( dev-cpp/gmock )
	test? ( dev-cpp/gtest )
	${RDEPEND}"

src_unpack() {
	cros-workon_src_unpack
	S+="/p2p"
}

pkg_preinst() {
	# Groups are managed in the central account database.
	enewgroup p2p
	enewuser p2p
}

src_prepare() {
	eautoreconf
}

src_configure() {
	clang-setup-env
	cros-workon_src_configure $(use_enable test tests)
}

src_test() {
	if ! use x86 && ! use amd64 ; then
		einfo "Skipping tests on non-x86 platform..."
	else
		# Needed for `cros_run_unit_tests`.
		cros-workon_src_test
	fi
}
