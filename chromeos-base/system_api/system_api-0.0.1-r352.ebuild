# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="081f38e473bd7f00ef0696a5c3abdf519b5f2f3a"
CROS_WORKON_TREE="4e27db1fa6c703ff5182ff6da836729708bfa2a1"
CROS_WORKON_PROJECT="chromiumos/platform/system_api"

inherit cros-workon toolchain-funcs

DESCRIPTION="Chrome OS system API (D-Bus service names, etc.)"
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="platform2"

src_prepare() {
	if use platform2; then
		printf '\n\n\n'
		ewarn "This package doesn't install anything with USE=platform2."
		ewarn "You want to use the new chromeos-base/platform2 package."
		printf '\n\n\n'
		return 0
	fi
	cros-workon_src_prepare
}

src_install() {
	use platform2 && return 0
	insinto /usr/include/chromeos
	doins -r dbus switches constants
}
