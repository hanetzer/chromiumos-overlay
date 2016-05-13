# Copyright 2014 The Chromium OS Authors.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="5fd37b66dcce77354e1cafab0d6e806d832c08d2"
CROS_WORKON_TREE="f9a5c47172786a443b824df89e2f3464c4de6026"
CROS_WORKON_PROJECT="chromiumos/third_party/coreboot"

DESCRIPTION="lp0 resume blob for Tegra"
HOMEPAGE="http://www.coreboot.org"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="arm"
IUSE=""

RDEPEND=""
DEPEND=""

CROS_WORKON_LOCALNAME="coreboot"

inherit cros-workon

src_compile() {
	emake -C src/soc/nvidia/tegra124/lp0 \
		GCC_PREFIX="${CHOST}-" || \
		die "tegra_lp0_resume build failed"
}

src_install() {
	insinto /lib/firmware/tegra12x/
	doins src/soc/nvidia/tegra124/lp0/tegra_lp0_resume.fw
}
