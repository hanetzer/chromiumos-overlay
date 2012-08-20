# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="ab6f9f9ed84ae882e95e6eb1285cc3c6b990e38e"
CROS_WORKON_TREE="e7a3d41df4ff1c87a0468ee0bc9be3aaf63a6fb4"

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
