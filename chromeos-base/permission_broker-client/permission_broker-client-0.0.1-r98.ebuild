# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT="56cc78d6b474abf7b151e208c92b31040a2a2497"
CROS_WORKON_TREE="8a64d579e84055cf25366cb0f75bee1e1539e95f"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_NATIVE_TEST="yes"
PLATFORM_SUBDIR="${PN%-client}"
PLATFORM_GYP_FILE="${PN}.gyp"

inherit cros-workon platform

DESCRIPTION="Permission Broker DBus client library for Chromium OS"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="cros_host"

DEPEND="
	cros_host? ( chromeos-base/chromeos-dbus-bindings )
"

src_install() {
	# Install DBus client library.
	platform_install_dbus_client_lib "permission_broker"
}
