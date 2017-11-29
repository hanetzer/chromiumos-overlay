# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="32fe60d364dfeba63e6ce81f3223a27f4e0b6a82"
CROS_WORKON_TREE="f47d5dd96c8d396e7c450d5e8973acd8cc16c102"
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
