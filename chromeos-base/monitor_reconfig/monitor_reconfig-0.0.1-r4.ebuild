# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="48f80ac47526ec99a371a754a54e846f04bae400"

inherit cros-workon toolchain-funcs

DESCRIPTION="Chrome OS Monitor Reconfig"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

DEPEND="chromeos-base/libchrome
	x11-libs/libX11
	x11-libs/libXrandr"

RDEPEND="${DEPEND}
	x11-apps/xrandr"

# TODO(msb): remove this hack
src_unpack() {
	cros-workon_src_unpack
	ln -s "${S}" "${S}/${PN}"
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
