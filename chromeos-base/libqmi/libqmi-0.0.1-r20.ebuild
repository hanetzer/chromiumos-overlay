# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="3e7997add6208f5d24130857cb3db2c361576a84"
CROS_WORKON_TREE="fc9753df2aea7f7e1c280991ceaf19c8f9807dcd"

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
