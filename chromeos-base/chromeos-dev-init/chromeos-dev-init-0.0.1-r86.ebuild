# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="e88efd0632b8fac75d9e975a6ab897518de47b82"
CROS_WORKON_TREE="b002d20460ceb64b9a4812c4ec2c19ce51662cb8"
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
