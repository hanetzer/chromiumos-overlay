# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="c6a4748736c2db0c969d79a04d9737bdf07ecbf3"
CROS_WORKON_TREE="12dc9e8f6952b70bc81a51390e401a508cbbb6f8"

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
