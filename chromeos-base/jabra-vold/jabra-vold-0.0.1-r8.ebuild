# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"
CROS_WORKON_COMMIT="71a0649db975ebaa056f65f3232f0dc0474eec6e"
CROS_WORKON_TREE="dcb3a35d2b1404e48052dd03533587faa76c74f2"
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
}
