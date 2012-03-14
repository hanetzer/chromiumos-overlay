# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="206d3ca0d9a63a7d917c38db1e74d83e67d8674b"
CROS_WORKON_PROJECT="chromiumos/platform/libqmi"

inherit cros-workon

DESCRIPTION="Library for communicating with QMI modems"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

src_install() {
	dolib src/libqmi.so
}
