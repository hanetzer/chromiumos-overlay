# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="c1ca38e6771d633f09bbd71a15db126af90afc23"
CROS_WORKON_TREE="3ab2f779175b230814095e68d1bae246c19873e7"

EAPI="4"

CROS_WORKON_PROJECT="chromiumos/platform/inputcontrol"

inherit cros-workon

DESCRIPTION="A collection of utilities for configuring input devices"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="+X"

RDEPEND="app-arch/gzip
	 x11-apps/xinput"
DEPEND="${RDEPEND}"

src_prepare() {
	if ! use X; then
		epatch "${FILESDIR}"/0001-chgrp-dev-input-devices-to-chronos-for-DRM.patch
	fi
}
