# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="7e64bd296c04841a6f6cfa590b5e77c619dfb66e"
CROS_WORKON_TREE="55bbb68e901ee68bf863fc28bb437262dc0c8414"

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
