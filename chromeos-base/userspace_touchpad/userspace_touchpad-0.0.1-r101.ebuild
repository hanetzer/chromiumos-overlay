# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="cbffbca9f40e90d087dc8ea4eb811cf3a9f222a9"
CROS_WORKON_TREE="efdff16d5483015b73a1fa782e4670a344a518e1"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_DESTDIR="${S}"
CROS_WORKON_OUTOFTREE_BUILD=1
PLATFORM_SUBDIR="userspace_touchpad"

inherit cros-workon platform

DESCRIPTION="Userspace Touchpad"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
IUSE=""
KEYWORDS="*"

src_install() {
	dobin "${OUT}/userspace_touchpad"

	insinto "/etc/init"
	doins "userspace_touchpad.conf"
}
