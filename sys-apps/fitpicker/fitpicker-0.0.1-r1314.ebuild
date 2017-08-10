# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="4dde7116c8fa54074ec3f2d823be8f664c455e41"
CROS_WORKON_TREE="218e216ca2dc9f0362172fc20f4afb1978d97ff4"
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
