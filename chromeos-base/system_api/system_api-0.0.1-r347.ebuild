# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="916c5d850ca4424b1de79e9e1054f34a23ee2e33"
CROS_WORKON_TREE="9a9c74d4f1852dbd9401166a1868b806e03abff1"
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
