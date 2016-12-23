# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="91ddfcb3d8e556d47010c68c448b7aab2f29e5e6"
CROS_WORKON_TREE="de69d6e50dab35c9bba2992666c33e61535f3ca8"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="authpolicy"

inherit cros-workon platform user

DESCRIPTION="Provides authentication to LDAP and fetching device/user policies"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="test"

RDEPEND="
	chromeos-base/libbrillo
	chromeos-base/chromeos-minijail
	dev-libs/protobuf
	dev-libs/dbus-glib
	sys-apps/dbus
"
DEPEND="
	${RDEPEND}
	>=chromeos-base/protofiles-0.0.2
	chromeos-base/system_api
	test? ( dev-cpp/gmock )
	dev-cpp/gtest
"

pkg_preinst() {
	# Create user and group for authpolicyd.
	enewuser "authpolicyd"
	enewgroup "authpolicyd"
}

src_install() {
	dosbin "${OUT}"/authpolicyd
	dosbin "${OUT}"/authpolicy_parser
	insinto /etc/dbus-1/system.d
	doins etc/dbus-1/org.chromium.AuthPolicy.conf
	insinto /etc/init
	doins etc/init/authpolicyd.conf
}

platform_pkg_test() {
	local tests=(
		authpolicy_test
	)

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done
}