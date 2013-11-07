# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="b8d86367208b98613c18aa4b164ef7c637cdbf85"
CROS_WORKON_TREE="0c7a019b4d54a4ce5df7669a2e586d0e6a160b90"
CROS_WORKON_PROJECT="chromiumos/platform/system_api"

inherit cros-workon toolchain-funcs

DESCRIPTION="Chrome OS system API (D-Bus service names, etc.)"
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"
IUSE="platform2"

src_install() {
	use platform2 && return 0
	insinto /usr/include/chromeos
	doins -r dbus switches
}
