# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="b65128a044fb1a214b7c13c9e87142005016eaef"
CROS_WORKON_TREE="227f2feea9cfd25d976e66f268cdd4ea224a95c9"

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
