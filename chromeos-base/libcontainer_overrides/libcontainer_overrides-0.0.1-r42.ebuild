# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="90ed206852fe245003b3ebe8ef4cd4c7539d9d60"
CROS_WORKON_TREE="9187ffd5e724671c50622cd13da7583f0f90b346"
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
