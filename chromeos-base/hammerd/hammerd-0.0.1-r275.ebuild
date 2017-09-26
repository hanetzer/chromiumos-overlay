# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT="6c976ef165ee22ddf274035d16b8e2071b29cb0f"
CROS_WORKON_TREE="805f2739dc5ba37e7a27801eb7f81f82c91ecd0b"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_DESTDIR="${S}/platform2"

PLATFORM_SUBDIR="hammerd"

inherit cros-workon platform user

DESCRIPTION="A daemon to update EC firmware of hammer, the base of the detachable."
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/hammerd/"

LICENSE="BSD-Google"
SLOT=0
KEYWORDS="*"

DEPEND="
	chromeos-base/libbrillo
	chromeos-base/system_api
	chromeos-base/vboot_reference
	dev-libs/openssl
	sys-apps/flashmap
	virtual/libusb:1
"
RDEPEND="${DEPEND}"

pkg_preinst() {
	# Create user and group for hammerd
	enewuser "hammerd"
	enewgroup "hammerd"
}

src_install() {
	dobin "${OUT}/hammerd"

	# Install upstart config.
	insinto /etc/init
	doins init/*.conf

	# Install exposed API.
	dolib.so "${OUT}"/lib/libhammerd-api.so
	insinto /usr/include/hammerd/
	doins hammerd_api.h

	# Install DBus config.
	insinto /etc/dbus-1/system.d
	doins dbus/org.chromium.hammerd.conf
}

platform_pkg_test() {
	platform_test "run" "${OUT}/unittest_runner"
}
