# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="0ca8bafed45e156eb05e818fe2aac8e2111c9fa2"
CROS_WORKON_TREE="0ce63545afaeee0ec7efeec57821ddd7ffc573d5"
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
