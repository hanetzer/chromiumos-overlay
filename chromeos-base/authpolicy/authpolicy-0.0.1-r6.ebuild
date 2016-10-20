# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="e18e7d41bc74e51fe73a0ed09c3ea4b7fb21d4e5"
CROS_WORKON_TREE="3e925204fd235622cadf70a4ed08651365e88f70"
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

pkg_preinst() {
	# Create user and group for authpolicyd.
	enewuser "authpolicyd"
	enewgroup "authpolicyd"
}

src_install() {
	dosbin "${OUT}"/authpolicyd
	insinto /etc/dbus-1/system.d
	doins etc/dbus-1/org.chromium.authpolicy.conf
	insinto /etc/init
	doins etc/init/authpolicyd.conf
}
