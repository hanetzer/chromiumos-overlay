# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="cb963e703103d6543d08fdddbd91beb121f2449a"
CROS_WORKON_TREE="0183782d840ce44ac45549128bf64bbf338d8a03"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="../platform2"
CROS_WORKON_DESTDIR="${S}"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="fitpicker"

inherit cros-workon platform

DESCRIPTION="Utility for picking a kernel/device tree from a FIT image."
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND=">=sys-apps/dtc-1.4.1"
DEPEND="${RDEPEND}"

src_install() {
	dobin "${OUT}"/fitpicker
}
