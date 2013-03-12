# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="dfffc9de9f57ba0aaa8de7ae32bea64ecaf14d38"
CROS_WORKON_TREE="14cdb3a62e942f69d30350c0bb1a357b3f39d608"
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
