# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="d5668905c34c603ce6c54545f59a8f9c24442d72"

inherit cros-workon

DESCRIPTION="Chrome OS workarounds utilities."
HOMEPAGE="http://src.chromium.org"
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
