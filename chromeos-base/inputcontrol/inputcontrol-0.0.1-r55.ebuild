# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT="8ca36eea1fc8a2fef119cd2ab4f56bf6305b4a5f"
CROS_WORKON_TREE="2a8b3afb569dc6560c42339fa50196d05a184278"
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
