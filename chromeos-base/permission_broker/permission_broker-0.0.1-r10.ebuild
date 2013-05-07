# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="12081be24610944006732f7dcaa4e85ed2c9e5e3"
CROS_WORKON_TREE="a89b754492b530d38f26995c316b896271909d3d"
CROS_WORKON_PROJECT="chromiumos/platform/permission_broker"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-debug cros-workon

DESCRIPTION="Permission Broker for Chromium OS"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"

LIBCHROME_VERS="180609"

RDEPEND="chromeos-base/platform2
	dev-cpp/gflags
	dev-cpp/glog
	dev-libs/glib
	dev-libs/libusb
	sys-fs/udev"

DEPEND="${RDEPEND}
	chromeos-base/libchrome:${LIBCHROME_VERS}[cros-debug=]
	test? ( dev-cpp/gmock )
	test? ( dev-cpp/gtest )"

src_prepare() {
	cros-workon_src_prepare
}

src_configure() {
	cros-workon_src_configure
}

src_compile() {
	cros-workon_src_compile
}

src_test() {
	if use arm ; then
		echo Skipping tests on non-x86 platform...
	else
		cros-workon_src_test
	fi
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
}
