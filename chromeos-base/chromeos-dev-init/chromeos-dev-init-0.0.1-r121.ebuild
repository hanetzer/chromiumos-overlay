# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="02f53a2539c38afe640eb371049e47d02ddb5c9b"
CROS_WORKON_TREE="6185961e1d62835c9506db9d56c4500a7f2fe904"
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
