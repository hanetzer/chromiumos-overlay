# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="adc85e3a20b77473f4ae2055bfa44a17df106e28"
CROS_WORKON_TREE="937d0561463e7580112ea26121a7f606cb09891d"

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
