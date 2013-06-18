# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="4c0e3dfeb981d780de2808b57389c11d00ece680"
CROS_WORKON_TREE="44aba3b1181a4bea1bc2f2af63dd09bed7e98fc1"
CROS_WORKON_PROJECT="chromiumos/platform/system_api"

inherit cros-workon toolchain-funcs

DESCRIPTION="Chrome OS system API (D-Bus service names, etc.)"
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="platform2"

src_install() {
	use platform2 && return 0
	insinto /usr/include/chromeos
	doins -r dbus switches
}
