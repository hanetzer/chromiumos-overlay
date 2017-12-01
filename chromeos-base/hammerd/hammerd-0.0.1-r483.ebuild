# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT="57ac7b0dd771f31db0c542743fd34e6d4d22b4af"
CROS_WORKON_TREE="cae0e053d6e37f16d9bf680e2c9fc4953cd8e2d8"
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
IUSE="-hammerd_api"

RDEPEND="
	chromeos-base/libbrillo
	chromeos-base/metrics
	chromeos-base/system_api
	chromeos-base/vboot_reference
	dev-libs/openssl
	sys-apps/flashmap
"
DEPEND="${RDEPEND}"

pkg_preinst() {
	# Create user and group for hammerd
	enewuser "hammerd"
	enewgroup "hammerd"
}

src_install() {
	dobin "${OUT}/hammerd"

	# Install upstart configs and scripts.
	insinto /etc/init
	doins init/*.conf
	exeinto /usr/share/cros/init
	doexe init/*.sh

	# Install DBus config.
	insinto /etc/dbus-1/system.d
	doins dbus/org.chromium.hammerd.conf
}

platform_pkg_test() {
	platform_test "run" "${OUT}/unittest_runner"
}
