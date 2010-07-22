# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="1f88776b9cc0338cdd0998e6d67e9b2be1988e73"
inherit cros-workon

DESCRIPTION="Chrome OS workarounds utilities."
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
KEYWORDS="x86 arm"
SLOT="0"
IUSE=""

#TODO(sosa) - Remove once file collisions have passed.

src_install() {
        dobin channel_change
        dobin crosh-workarounds
	dobin generate_logs
        dobin mkcrosusb
        dobin wlan_11n
        dobin wlan_tx_ampdu
}
