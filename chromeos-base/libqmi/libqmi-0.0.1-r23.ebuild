# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="b6fee418eaa6a48718c2a309dfb5a55bfbbc82f8"
CROS_WORKON_TREE="717134ceed3b8f3210c8354a000dec0c0e524789"

EAPI=4
CROS_WORKON_PROJECT="chromiumos/platform/libqmi"

inherit cros-workon multilib

DESCRIPTION="Library for communicating with QMI modems"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

src_install() {
	emake DESTDIR="${D}" LIBDIR="/usr/$(get_libdir)" install
}
