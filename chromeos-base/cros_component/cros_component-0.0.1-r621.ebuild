# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"
CROS_WORKON_COMMIT="b61618a6899b369c5c2836ff06d63d172512d819"
CROS_WORKON_TREE="e39424cc446923f01c811b1ed9c4b7f4673ae1e9"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="cros_component"

inherit cros-workon platform

DESCRIPTION="Configurations for Chrome OS universial installer"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

src_compile() {
	true
}

src_install() {
	insinto /etc
	doins cros_component.config
}
