# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="3f8d9c4da4d8b7ff4830e08f72a103c9c03114a5"
CROS_WORKON_TREE="280d998a04fae2631af416ef637e0fd729794b1a"
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

	insinto /etc/init
	doins init/*.conf
}
