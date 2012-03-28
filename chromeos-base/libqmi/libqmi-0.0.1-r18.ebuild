# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="ca38d13951ebf4c32a169d1ed3360350cbc4b147"
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
