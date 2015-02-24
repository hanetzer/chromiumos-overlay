# Copyright 2014 The Chromium OS Authors.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="e0db2cb9f7b53631b040d1346f3fa34a4f5562dd"
CROS_WORKON_TREE="0767cd2588abdc47316c2cc6979bd1c104b22e78"
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
	emake -C src/soc/nvidia/tegra132/lp0 \
		GCC_PREFIX="${CHOST}-" || \
		die "tegra_lp0_resume build failed"
}

src_install() {
	insinto /lib/firmware/tegra13x/
	doins src/soc/nvidia/tegra132/lp0/tegra_lp0_resume.fw
}
