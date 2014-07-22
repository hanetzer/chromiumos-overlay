# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="c36a4115353d61e6457a055014ca78f6b0d4f45d"
CROS_WORKON_TREE="c7b135fe38fc3bf9239555ae4ff8d691b99fefa8"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_DESTDIR="${S}"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-debug cros-workon udev user

DESCRIPTION="Permission Broker for Chromium OS"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="-asan -clang"
REQUIRED_USE="asan? ( clang )"
RESTRICT="test"

LIBCHROME_VERS="271506"

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
