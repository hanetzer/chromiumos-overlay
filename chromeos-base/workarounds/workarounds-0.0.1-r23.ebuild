# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="053c75ca2eeb411463e3b142fd2fcb4778c7394c"

inherit cros-workon

DESCRIPTION="Chrome OS workarounds utilities."
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
KEYWORDS="x86 arm"
SLOT="0"
IUSE=""

#TODO(sosa) - Remove once file collisions have passed.
RDEPEND="chromeos-base/metrics"

src_install() {
        dobin channel_change
        dobin crosh-workarounds
	dobin generate_logs
}
