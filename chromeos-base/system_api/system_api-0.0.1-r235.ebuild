# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="fc8b428c60e2858de4d61009ac950414e21c4aa8"
CROS_WORKON_TREE="502625647b8a9da1c7bfd06420f7415dfb8cfc36"
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
