# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="f433430cb28ff70839b4c6d404bd304bb659df26"
CROS_WORKON_TREE="364ae3f7642d4b1e8e94fb948c9e657c42a1b4e6"
CROS_WORKON_PROJECT="chromiumos/platform/workarounds"

inherit cros-workon

DESCRIPTION="Chrome OS workarounds utilities."
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="BSD"
KEYWORDS="*"
SLOT="0"
IUSE=""

RDEPEND=""

src_install() {
	dobin generate_logs
}
