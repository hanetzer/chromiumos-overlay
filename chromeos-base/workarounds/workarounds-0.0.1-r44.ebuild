# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="afcc9e27e7f0a6a211c0fefbe9c9539399a3c338"
CROS_WORKON_TREE="31c0d30cb9d71b44be47d7ff16d47c7127c7359b"

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
