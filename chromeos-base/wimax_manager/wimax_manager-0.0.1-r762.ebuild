# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="a63fc68a1ed6b7f7584ec99fb4d44aea6e9fae9c"
CROS_WORKON_TREE="b834573ae76009f9ab54c81faebfeb6f97ff028e"
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
IUSE="gdmwimax test"

RDEPEND="
	dev-libs/dbus-c++
	gdmwimax? (
		chromeos-base/libchromeos
		chromeos-base/metrics
		>=dev-libs/glib-2.30
		dev-libs/protobuf
		virtual/gdmwimax
	)
"

DEPEND="
	${RDEPEND}
	gdmwimax? ( chromeos-base/system_api )
	test? (	dev-cpp/gmock )
	dev-cpp/gtest
"

src_install() {
	# Install D-Bus introspection XML files.
	insinto /usr/share/dbus-1/interfaces
	doins dbus_bindings/org.chromium.WiMaxManager*.xml

	# Install the dbus proxies needed by shill.
	insinto /usr/include/wimax_manager
	doins -r "${OUT}"/gen/include/wimax_manager/dbus_proxies

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
