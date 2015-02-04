# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# NOTE: This ebuild could be overridden in an overlay to provide a
# board-specific xorg.conf as necessary.

EAPI=4
CROS_WORKON_COMMIT="1c56c26cd43dc1be39734f7b4432974f8835893e"
CROS_WORKON_TREE="7ac511dcd3d0605b13b7d06bef95faf017da751d"
CROS_WORKON_PROJECT="chromiumos/platform/xorg-conf"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-workon user

DESCRIPTION="Board specific xorg configuration file."
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="-exynos -tegra -rk32 X"

RDEPEND=""
DEPEND="X? ( x11-base/xorg-server )"

src_install() {
	insinto /etc/X11
	if ! use tegra; then
		doins xorg.conf
	fi

	insinto /etc/X11/xorg.conf.d
	if use tegra; then
		doins tegra.conf
	elif use exynos; then
		doins exynos.conf
	elif use rk32; then
		doins rk32.conf
	fi

	doins 20-touchscreen.conf
}

pkg_preinst() {
	enewuser "xorg"
	enewgroup "xorg"
}
