# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="047d2c6891bad88fea7748cc150a675721a3492c"
CROS_WORKON_TREE="a880b9cf249760f299fb8240a2f4aa1aa909149a"

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
