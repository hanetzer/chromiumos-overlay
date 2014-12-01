# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Copyright 2013-2014 Broadcom Corporation
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_PROJECT="chromiumos/third_party/broadcom"

inherit cros-workon toolchain-funcs

DESCRIPTION="Broadcom Bluetooth Patchram Plus Firmware Download Tool"
HOMEPAGE="http://www.broadcom.com/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="-* ~arm"
IUSE=""

RESTRICT="binchecks"

src_compile() {
	tc-export AR CC
	emake -C bluetooth
}

src_install() {
    emake -C bluetooth DESTDIR="${D}" install
}
