# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="2403b8aebc1a2b81780fae6dc228fa22ff534101"
CROS_WORKON_TREE="e186cf7b1f7f6aaadd6dd3b826fbdb6c0796ce75"
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
