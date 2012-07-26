# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT=a446bfcf199f84abed54b0e6e2d272f1850c5e01
CROS_WORKON_TREE="b09d240ea74eb52a54ed9fbef9f910dec089b8bf"

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
