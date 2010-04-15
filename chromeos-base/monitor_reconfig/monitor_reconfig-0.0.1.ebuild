# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit toolchain-funcs

DESCRIPTION="Chrome OS Monitor Reconfig"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE=""

DEPEND="chromeos-base/libchrome
	x11-libs/libX11
	x11-libs/libXrandr"

RDEPEND="${DEPEND}
	x11-apps/xrandr"

src_unpack() {
	local platform="${CHROMEOS_ROOT}/src/platform"
	elog "Using platform: $platform"
	mkdir -p "${S}/monitor_reconfig"
	cp -a "${platform}"/monitor_reconfig/* "${S}/monitor_reconfig" || die
}

src_compile() {
	tc-export CXX PKG_CONFIG
	pushd monitor_reconfig
	emake monitor_reconfigure || die "monitor_reconfigure compile failed."
	popd
}

src_install() {
	dosbin monitor_reconfig/monitor_reconfigure
}
