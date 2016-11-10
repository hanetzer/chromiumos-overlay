# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="80c0d7bb07ce5064bbd0e5451b951be2023d050c"
CROS_WORKON_TREE="82ea7448ca9ed999cf3738b24ba2f6796271baec"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
PLATFORM_SUBDIR="libcontainer_overrides"

inherit cros-workon platform

DESCRIPTION="Provide preload library for generic containers"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

src_install() {
	dolib.so "${OUT}/lib/libcontainer_overrides.so"
}
