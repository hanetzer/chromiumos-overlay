# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="2edf3c2ace8f29f858d888cd30298979bacc6b2a"
CROS_WORKON_TREE="b7acd943855130485b8dd3d341154d90ca21d6b0"

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
