# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT=34e82037b1ab733e493e77bf8dd2c14b7fab785b
CROS_WORKON_TREE="fa8d0a56dcd7ded6beb7d13bd5e5b6ac7ca3302a"

EAPI=2
CROS_WORKON_PROJECT="chromiumos/platform/crosh"

# Files from chromeos-wm are being moved to this package; ensure that we don't
# get conflicts by installing this and an old version of chromeos-wm at the
# same time.
CONFLICT_LIST="chromeos-base/chromeos-wm-0.0.1-r230"
inherit cros-workon toolchain-funcs conflict

DESCRIPTION="Chrome OS command-line shell"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"

RDEPEND="chromeos-base/vboot_reference
	net-misc/iputils
	net-wireless/iw
	sys-apps/net-tools
	x11-terms/rxvt-unicode"
DEPEND=""

src_install() {
	dobin cros-term
	dobin crosh
	dobin crosh-dev
	dobin crosh-usb
	dobin inputrc.crosh
	dobin network_diagnostics
}
