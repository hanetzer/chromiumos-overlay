# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="7939934b13e08083807af4a534d92a245e3c3578"

inherit cros-workon

DESCRIPTION="Chrome OS workarounds utilities."
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
KEYWORDS="x86 arm"
SLOT="0"
IUSE=""

#TODO(sosa) - Remove once file collisions have passed.
RDEPEND="chromeos-base/metrics"

src_install() {
        dobin channel_change
        dobin crosh-workarounds
	dobin generate_logs
        dobin mkcrosusb
        dobin wlan_11n
        dobin wlan_tx_ampdu
}
