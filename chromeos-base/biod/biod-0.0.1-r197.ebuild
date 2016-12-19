# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="1b7a8361db19bacf468e5b41ba79cf24c79f185d"
CROS_WORKON_TREE="fcea5d26e3aaf5cba64c1598ad8459b87ea2e9dd"
CROS_WORKON_USE_VCSID="1"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="biod"

inherit cros-workon platform user

DESCRIPTION="Biometrics Daemon for Chromium OS"
HOMEPAGE="http://dev.chromium.org/chromium-os/packages/biod"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

# util-linux is for libuuid.
RDEPEND="
	chromeos-base/libbrillo
	chromeos-base/libchrome
	sys-apps/util-linux"

DEPEND="${RDEPEND}"

src_install() {
	dobin "${OUT}"/biod

	into /usr/local
	dobin "${OUT}"/biod_client_tool
	dobin "${OUT}"/fake_biometric_tool

	insinto /etc/init
	doins init/*.conf

	insinto /etc/dbus-1/system.d
	doins dbus/org.chromium.BiometricsDaemon.conf
}

pkg_preinst() {
        enewuser biod
        enewgroup biod
}
