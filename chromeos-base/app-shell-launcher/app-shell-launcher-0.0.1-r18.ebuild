# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT="55734e55e2687342758aa83e5350b6c42d53b903"
CROS_WORKON_TREE="7d7a405903fb4401a8f2f09b8d86430e9eeb2186"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_USE_VCSID=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_DESTDIR="${S}/platform2"

PLATFORM_SUBDIR="app_shell_launcher"

inherit cros-workon platform

DESCRIPTION="Launcher for the app_shell binary"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
RDEPEND="chromeos-base/chromeos-chrome[app_shell]"

src_install() {
	dobin "${OUT}/app_shell_launcher"
	insinto /etc/init
	doins init/*.conf
}
