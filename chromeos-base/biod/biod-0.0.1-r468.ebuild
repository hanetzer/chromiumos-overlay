# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="a34f81648ff81edb316aff722c39f3afd41b5149"
CROS_WORKON_TREE="94b7b580e731a9fed0bc89afec6afc316dc47172"
CROS_WORKON_USE_VCSID="1"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="biod"

inherit cros-workon platform udev user

DESCRIPTION="Biometrics Daemon for Chromium OS"
HOMEPAGE="http://dev.chromium.org/chromium-os/packages/biod"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	chromeos-base/libbrillo
	chromeos-base/libchrome
	"

DEPEND="
	${RDEPEND}
	chromeos-base/system_api
	"

src_install() {
	dobin "${OUT}"/biod

	into /usr/local
	dobin "${OUT}"/biod_client_tool
	dobin "${OUT}"/fake_biometric_tool

	insinto /etc/init
	doins init/*.conf

	insinto /etc/dbus-1/system.d
	doins dbus/org.chromium.BiometricsDaemon.conf

	udev_dorules udev/99-biod.rules
}

pkg_preinst() {
        enewuser biod
        enewgroup biod
}

platform_pkg_test() {
	platform_test "run" "${OUT}/biod_test_runner"
}
