# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="ef8b6d3349e7bb3b8e0e28591cd38f3281830e2e"
CROS_WORKON_TREE="fb87568eb7200085294b978286935401b8822bb0"

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
