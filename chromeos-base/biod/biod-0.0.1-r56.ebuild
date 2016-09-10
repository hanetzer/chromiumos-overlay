# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="e2a93f6bf3d838e43a0d1d7101855df21c11ed5e"
CROS_WORKON_TREE="6bb1c64c05a3d3e00b9377c4cbe169ee52914fa7"
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

RDEPEND="
	chromeos-base/libbrillo
	chromeos-base/libchrome"

DEPEND="${RDEPEND}"

src_install() {
	dobin "${OUT}"/biod

	into /usr/local
	dobin "${OUT}"/fake_biometric_tool

	insinto /etc/init
	doins init/*.conf
}

pkg_preinst() {
        enewuser biod
        enewgroup biod
}
