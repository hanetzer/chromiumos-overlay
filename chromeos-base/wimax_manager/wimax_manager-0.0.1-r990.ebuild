# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="e33f851cc50bca67281c831fa9b61f8e83748e7b"
CROS_WORKON_TREE="d5b53ffe0c99e633dc7820370f6a0bc01bc8c1ae"
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
