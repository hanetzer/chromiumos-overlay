# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT="e1062e8077790a71dda3c78d47baf8b27c69913d"
CROS_WORKON_TREE="e18be86534f12d1db1ec1f9909fee36aa5e2f361"
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
IUSE="+samba"

RDEPEND="
	app-crypt/mit-krb5
	chromeos-base/libbrillo
	chromeos-base/metrics
	>=chromeos-base/chromeos-minijail-0.0.1-r1477
	dev-libs/protobuf
	dev-libs/dbus-glib
	samba? ( >=net-fs/samba-4.5.3-r6 )
	sys-apps/dbus
	sys-libs/libcap
"
DEPEND="
	${RDEPEND}
	chromeos-base/protofiles:=
	chromeos-base/system_api
"

pkg_preinst() {
	# Create user and group for authpolicyd and authpolicyd-exec.
	enewuser "authpolicyd"
	enewgroup "authpolicyd"
	enewuser "authpolicyd-exec"
	enewgroup "authpolicyd-exec"
}

src_install() {
	dosbin "${OUT}"/authpolicyd
	dosbin "${OUT}"/authpolicy_parser
	insinto /etc/dbus-1/system.d
	doins etc/dbus-1/org.chromium.AuthPolicy.conf
	insinto /etc/init
	doins etc/init/authpolicyd.conf
	insinto /usr/share/policy
	doins seccomp_filters/*.policy
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
