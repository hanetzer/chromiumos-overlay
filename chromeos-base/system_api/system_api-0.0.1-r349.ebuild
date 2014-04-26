# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="a4d5c35ae70a53dce3ca3d4f4793a75528973145"
CROS_WORKON_TREE="5b6a69ed50c1b348265c656ae5ad4f7a2dfefdb3"
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
