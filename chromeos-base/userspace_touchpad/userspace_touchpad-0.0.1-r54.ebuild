# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="0e20b19e4cc5fa3ff1cd1dc24788a9d0f000c0b2"
CROS_WORKON_TREE="9eaa80dcc4a53d4bd558da38043ebefc6770cec1"
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
