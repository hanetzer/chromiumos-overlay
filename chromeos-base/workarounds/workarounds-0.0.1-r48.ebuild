# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="a931ea718498562fe0bbcf0a34ba4d28a97b208f"
CROS_WORKON_TREE="ca092d2f66017c77c97620f4f8fd302be7ab4cd2"

EAPI=2
CROS_WORKON_PROJECT="chromiumos/platform/workarounds"

inherit cros-workon

DESCRIPTION="Chrome OS workarounds utilities."
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="BSD"
KEYWORDS="amd64 arm x86"
SLOT="0"
IUSE=""

RDEPEND=""

src_install() {
	dobin crosh-workarounds
	dobin generate_logs
}
