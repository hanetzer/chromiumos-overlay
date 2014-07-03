# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT="5e8ac9d68bd909fca2f28ea17cf2f8517bf7dc18"
CROS_WORKON_TREE="5fd193ae3e32fd4cef9f6ca5ad2d6653344936e4"
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
