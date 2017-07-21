# Copyright (c) 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="5b23d075f2bb238a72db3f3da50a41dafe390117"
CROS_WORKON_TREE="8abf74308ef45ff18e951422e0cd26437a2c9598"
CROS_WORKON_PROJECT="chromiumos/platform/chameleon"

inherit cros-workon

DESCRIPTION="Chameleon bundle for Autotest lab deployment"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="dev-lang/python"
DEPEND="${RDEPEND}"

src_install() {
	local base_dir="/usr/share/chameleon-bundle"
	insinto "${base_dir}"
	newins dist/chameleond-*.tar.gz chameleond-${PVR}.tar.gz
}
