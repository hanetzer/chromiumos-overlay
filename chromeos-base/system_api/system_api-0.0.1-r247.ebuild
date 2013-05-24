# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="1a1724c66ebed6cca383d8fd0d23ca9b29ef80a3"
CROS_WORKON_TREE="e8351f1d38f7ba1c1c9348a7483937a826029e25"
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
