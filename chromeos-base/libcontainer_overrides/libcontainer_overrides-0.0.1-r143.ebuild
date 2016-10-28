# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="64308069410ab423223e48c8e78fc665c557d612"
CROS_WORKON_TREE="7c4785e95d9d5d1a310a7107154a56aeb0121934"
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
