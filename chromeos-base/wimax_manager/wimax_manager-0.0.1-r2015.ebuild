# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="0a09d6fcc25dacb2dd29f0eeeed8b264f51ab90b"
CROS_WORKON_TREE="b36cebffd3f3e0631914d94a83c923e750a479f0"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_USE_VCSID=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="wimax_manager"

inherit cros-workon platform

DESCRIPTION="Chromium OS WiMAX Manager"
HOMEPAGE="http://dev.chromium.org/chromium-os/platform"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="gdmwimax"

RDEPEND="
	dev-libs/dbus-c++
	gdmwimax? (
		chromeos-base/libbrillo
		chromeos-base/metrics
		>=dev-libs/glib-2.30
		dev-libs/protobuf
		virtual/gdmwimax
	)
"

DEPEND="
	${RDEPEND}
	gdmwimax? ( chromeos-base/system_api )
"

src_install() {
	# Install D-Bus introspection XML files.
	insinto /usr/share/dbus-1/interfaces
	doins dbus_bindings/org.chromium.WiMaxManager*.xml

	# Install D-Bus client library.
	platform_install_dbus_client_lib

	# Skip the rest of the files unless USE=gdmwimax is specified.
	use gdmwimax || return 0

	# Install daemon executable.
	dosbin "${OUT}"/wimax-manager

	# Install WiMAX Manager default config file.
	insinto /usr/share/wimax-manager
	doins default.conf

	# Install upstart config file.
	insinto /etc/init
	doins wimax_manager.conf

	# Install D-Bus config file.
	insinto /etc/dbus-1/system.d
	doins dbus_bindings/org.chromium.WiMaxManager.conf
}

platform_pkg_test() {
	use gdmwimax || return 0

	platform_test "run" "${OUT}/wimax_manager_testrunner"
}
