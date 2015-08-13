# Copyright 2014 The Chromium OS Authors.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="2c931120b81f8d0ebd927b79107aa26861609afc"
CROS_WORKON_TREE="2ecb39f55bf7e825c92472b20e186057161b8b8e"
CROS_WORKON_PROJECT="chromiumos/third_party/coreboot"

DESCRIPTION="lp0 resume blob for Tegra"
HOMEPAGE="http://www.coreboot.org"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="-* arm arm64"
IUSE=""

RDEPEND=""
DEPEND=""

CROS_WORKON_LOCALNAME="coreboot"

inherit cros-workon

src_compile() {
	emake -C src/soc/nvidia/tegra210/lp0 \
		GCC_PREFIX="${CHOST}-" || \
		die "tegra_lp0_resume build failed"
}

src_install() {
	insinto /lib/firmware/nvidia/tegra210/
	doins src/soc/nvidia/tegra210/lp0/tegra_lp0_resume.fw
}
