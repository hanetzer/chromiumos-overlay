# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="d342c1035b552e782d808f622d550692e5f33147"
CROS_WORKON_TREE="0cc3801d9002d708975b11c70111ad63e519be18"

EAPI="4"
CROS_WORKON_PROJECT="chromiumos/platform/crosh"

inherit cros-workon

DESCRIPTION="Chrome OS command-line shell"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

RDEPEND="chromeos-base/vboot_reference
	net-misc/iputils
	net-wireless/iw
	sys-apps/net-tools"
DEPEND=""

src_install() {
	dobin crosh
	dobin crosh-dev
	dobin crosh-usb
	dobin inputrc.crosh
	dobin network_diagnostics
}
