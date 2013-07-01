# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="1222289c4c98f133683918c4ec4fdd97545b7604"
CROS_WORKON_TREE="788c566a2209989f333f7e065c8212b87615ea05"
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
