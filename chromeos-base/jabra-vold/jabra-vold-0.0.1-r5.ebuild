# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"
CROS_WORKON_COMMIT="291ace21ab80bc562e7c572342229b29ac18996d"
CROS_WORKON_TREE="f9383a507eed0ba980300d89def54738ec65c4b4"
CROS_WORKON_PROJECT="chromiumos/platform/jabra_vold"
CROS_WORKON_LOCALNAME="jabra_vold"

inherit cros-workon toolchain-funcs

DESCRIPTION="A simple daemon to handle Jabra speakerphone volume change"
SRC_URI=""

LICENSE="BSD"
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

	insinto /etc/udev/rules.d
	doins 99-jabra.rules

	insinto /etc/init
	doins jabra-vold.conf
}
