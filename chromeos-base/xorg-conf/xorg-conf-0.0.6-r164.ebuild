# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# NOTE: This ebuild could be overridden in an overlay to provide a
# board-specific xorg.conf as necessary.

EAPI=4
CROS_WORKON_COMMIT="1de9157b9d56e5bba84fc43809c0d4d77302945d"
CROS_WORKON_TREE="a3ebcdabf5e3d96554eea016eed2dac0f2b37df3"
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
