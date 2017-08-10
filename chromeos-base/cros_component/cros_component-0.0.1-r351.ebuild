# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"
CROS_WORKON_COMMIT="54a0122de3d6e00fa2b73ce0994e7a54a29e33b2"
CROS_WORKON_TREE="7ba687370f16d8edb46b8e13b5a00b5552b90e5a"
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
