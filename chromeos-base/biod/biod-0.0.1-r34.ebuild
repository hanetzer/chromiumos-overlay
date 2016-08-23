# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="9b086a29df8242700eb9335c5e8e0e0030c78e27"
CROS_WORKON_TREE="286e8bf5c4a24a3579e1366bcb274c660650ee81"
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
