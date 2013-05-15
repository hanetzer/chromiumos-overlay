# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="f167b8bae013dcbf86167c91ca81280b7b62ad2a"
CROS_WORKON_TREE="58abe5ce08c9866e90d20e58bcf7417ca67f92d8"
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
