# Copyright (c) 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="6048d00917371ef43308f65419e5e0bbf7f7db7e"
CROS_WORKON_TREE="b329a992819d48eb3c9575e2d76e040b424253fa"
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
