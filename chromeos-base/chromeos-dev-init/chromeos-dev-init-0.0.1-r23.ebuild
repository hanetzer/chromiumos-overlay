# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="a729b1c3a593e041bcae894eff5c42883b942b7f"
CROS_WORKON_TREE="55a166fb2beac160e1de52768565b77d4ea17f5c"

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
