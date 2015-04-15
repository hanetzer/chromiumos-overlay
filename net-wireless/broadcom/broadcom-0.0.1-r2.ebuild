# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Copyright 2013-2014 Broadcom Corporation
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="4070e7161f2f1a1a22027a744eb868500688f0b6"
CROS_WORKON_TREE="d9f76b147ec19d811d540af00b79632194428b77"
CROS_WORKON_PROJECT="chromiumos/third_party/broadcom"

inherit cros-workon toolchain-funcs

DESCRIPTION="Broadcom Bluetooth Patchram Plus Firmware Download Tool"
HOMEPAGE="http://www.broadcom.com/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="-* arm"
IUSE=""

RDEPEND="net-wireless/bluez"
DEPEND="${RDEPEND}"

RESTRICT="binchecks"

src_compile() {
	tc-export AR CC
	emake -C bluetooth
}

src_install() {
    emake -C bluetooth DESTDIR="${D}" install
}
