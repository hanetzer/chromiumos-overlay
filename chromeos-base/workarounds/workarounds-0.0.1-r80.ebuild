# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="77bbb91d36f89bc13a7672f3023d45e0502fcc8b"
CROS_WORKON_TREE="d69681f922ca7ad388d4b1a06cfba9790ab02a25"
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
	dobin crosh-workarounds
	dobin generate_logs
}
