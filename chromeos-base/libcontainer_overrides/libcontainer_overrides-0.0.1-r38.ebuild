# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="ecfe48055571b825d83f15cd7df04f58de0b2bd7"
CROS_WORKON_TREE="1f36ced34122f53774375fcbf4e842beffa00568"
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
