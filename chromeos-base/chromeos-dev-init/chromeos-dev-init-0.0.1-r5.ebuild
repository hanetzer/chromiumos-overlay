# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="9d8ea35d1c2f4a015f4cff2cfd40fb56e403e49f"
CROS_WORKON_TREE="a0f0b32fef912fd724c8261d6a4f4963462bdffd"

EAPI="4"
CROS_WORKON_PROJECT="chromiumos/platform/init"
CROS_WORKON_LOCALNAME="init"

inherit cros-workon

DESCRIPTION="Additional upstart jobs that will be installed on dev images"
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"

DEPEND="chromeos-base/chromeos-init"
RDEPEND="${DEPEND}"

src_install() {
	insinto /etc/init
	insopts --owner=root --group=root --mode=0644
	doins dev-init/*.conf
}
