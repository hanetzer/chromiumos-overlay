# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# NOTE: This ebuild could be overridden in an overlay to provide a
# board-specific xorg.conf as necessary.

EAPI=4
CROS_WORKON_COMMIT="e60da1452c9000e8e813c8f029fe7073ddc76bc3"
CROS_WORKON_TREE="b267b96243f5acc1c6e01e4f943c599e10ec6f01"
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
