# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="10288dd376e6ce321187dfa3b8ef5c87fe986d9f"
CROS_WORKON_TREE=("903136741a0802ef6d2c7cf4820a19218646f7ec" "2f0635e921bc38819d1c6b1d00e055048e85ef7b" "cba1b0ffaecbbeaf663966b4cf04552d1a0dd30c")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_USE_VCSID=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
# TODO(crbug.com/809389): Avoid directly including headers from other packages.
CROS_WORKON_SUBTREE="common-mk power_manager wimax_manager"

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
