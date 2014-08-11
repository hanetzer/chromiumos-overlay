# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="54c1d4c99886fb380327bbc9789b01697dbe827e"
CROS_WORKON_TREE="0f008aae4a3474378639aeef5a9fa7591e82d5de"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_DESTDIR="${S}"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-debug cros-workon libchrome udev user

DESCRIPTION="Permission Broker for Chromium OS"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="-asan -clang"
REQUIRED_USE="asan? ( clang )"
RESTRICT="test"

RDEPEND="chromeos-base/libchromeos
	>=dev-cpp/gflags-2.0
	dev-cpp/glog
	dev-libs/glib
	dev-libs/libusb
	sys-fs/udev"

DEPEND="${RDEPEND}
	chromeos-base/system_api
	dev-cpp/gmock
	dev-cpp/gtest"

src_unpack() {
	cros-workon_src_unpack
	S+="/permission_broker"
}

src_prepare() {
	cros-workon_src_prepare
}

src_configure() {
	clang-setup-env
	cros-workon_src_configure
}

src_compile() {
	cros-workon_src_compile
}

pkg_preinst() {
	enewuser "devbroker"
	enewgroup "devbroker"
	enewgroup "devbroker-access"
}

src_install() {
	cros-workon_src_install
	# Built binaries
	pushd "${OUT}" >/dev/null
	dobin permission_broker
	popd >/dev/null

	# Install upstart configuration
	insinto /etc/init
	doins permission_broker.conf

	# DBus configuration
	insinto /etc/dbus-1/system.d
	doins dbus/org.chromium.PermissionBroker.conf

	# Udev rules for hidraw nodes
	udev_dorules "${FILESDIR}/99-hidraw.rules"
}
