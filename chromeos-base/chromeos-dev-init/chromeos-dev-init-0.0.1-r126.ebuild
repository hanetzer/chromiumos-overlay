# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="6445bc1e84095198cd08e1916b5fd0eb190e8426"
CROS_WORKON_TREE="6a1f73a3b7dea91c20a39f9b97c0689927674974"
CROS_WORKON_PROJECT="chromiumos/platform/init"
CROS_WORKON_LOCALNAME="init"

inherit cros-workon

DESCRIPTION="Additional upstart jobs that will be installed on dev images"
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="cros_embedded"

DEPEND="!cros_embedded? ( chromeos-base/chromeos-init )
	 cros_embedded? ( chromeos-base/chromeos-embedded-init )
"
RDEPEND="${DEPEND}"

src_install() {
	insinto /etc/init
	insopts --owner=root --group=root --mode=0644
	doins dev-init/*.conf
}
