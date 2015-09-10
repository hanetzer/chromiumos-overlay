# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT="2a561677636dc2ab4399cfe47e38d855036ea0f5"
CROS_WORKON_TREE="2d4ec5d346a1e47376dfae7e1275020d285b97e3"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_NATIVE_TEST="yes"
PLATFORM_SUBDIR="login_manager"
PLATFORM_GYP_FILE="${PN}.gyp"

inherit cros-workon platform

DESCRIPTION="Session manager (chromeos-login) DBus client library for Chromium OS"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="
	!<chromeos-base/chromeos-login-0.0.2
"

src_install() {
	# Install DBus client library.
	platform_install_dbus_client_lib "session_manager"
}
