# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
CROS_WORKON_COMMIT="8830911158ae632b7626d0ebe33248e66ffaeef3"
CROS_WORKON_TREE="5014633607a77f9f9954207189b7e80f1a845154"
CROS_WORKON_PROJECT="chromiumos/platform/jabra_vold"
CROS_WORKON_LOCALNAME="jabra_vold"

inherit cros-workon toolchain-funcs udev user

DESCRIPTION="A simple daemon to handle Jabra speakerphone volume change"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND=">=media-libs/alsa-lib-1.0"
DEPEND="${RDEPEND}"

src_compile() {
	tc-export CC PKG_CONFIG

	emake
}

src_install() {
	dosbin jabra_vold

	udev_dorules 99-jabra{,-usbmon}.rules
}

pkg_preinst() {
	enewuser "volume"
	enewgroup "volume"
}
