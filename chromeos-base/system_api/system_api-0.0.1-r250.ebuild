# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="f893cdefbf398e65270b9f8a5aa924dfb1e74342"
CROS_WORKON_TREE="d476cbd79ef67ed56315a855c209d0e765996f74"
CROS_WORKON_PROJECT="chromiumos/platform/system_api"

inherit cros-workon toolchain-funcs

DESCRIPTION="Chrome OS system API (D-Bus service names, etc.)"
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"

src_install() {
	insinto /usr/include/chromeos
	doins -r dbus switches
}
