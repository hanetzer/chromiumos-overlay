# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="d0364e39af4926acc4d5a6c4ef8922c68ed614ab"
CROS_WORKON_TREE="5a8fa8ddfb82e39c02783f2d7778e717cd6606e7"
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
