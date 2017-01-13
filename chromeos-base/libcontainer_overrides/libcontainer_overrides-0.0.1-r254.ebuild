# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="36051424abf420ffcc1632d9bb53c6da2e01377a"
CROS_WORKON_TREE="054ad9e4dadb224105184d294a8038cea26d17f1"
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

RDEPEND="chromeos-base/libbrillo"
DEPEND="${RDEPEND}"

src_install() {
	dolib.so "${OUT}/lib/libcontainer_overrides.so"
}
