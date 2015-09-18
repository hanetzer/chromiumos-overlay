# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT="ceee48dc568571696af0a86e2b301e6a9120bc72"
CROS_WORKON_TREE="04f962b04cc98fa2e7c89b88afc62f1490341088"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_NATIVE_TEST="yes"
PLATFORM_SUBDIR="${PN%-client}"
PLATFORM_GYP_FILE="${PN}.gyp"

inherit cros-workon platform

DESCRIPTION="Power manager DBus client library for Chromium OS"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="cros_host"

DEPEND="
	cros_host? ( chromeos-base/chromeos-dbus-bindings )
"

RDEPEND="
	!<chromeos-base/power_manager-0.0.2
"

src_install() {
	# Install DBus client library.
	platform_install_dbus_client_lib "power_manager"
}
