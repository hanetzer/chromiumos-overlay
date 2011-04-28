# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="5935579ff945752851fc9e859b7569097b5efa17"

inherit cros-workon

DESCRIPTION="Chrome OS workarounds utilities."
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="BSD"
KEYWORDS="x86 arm"
SLOT="0"
IUSE=""

RDEPEND=""

src_install() {
	dobin crosh-workarounds
	dobin generate_logs
}
