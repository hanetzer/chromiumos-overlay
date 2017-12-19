# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

CROS_WORKON_COMMIT="4a5eddde6fa2879be596a8ff9dbcbe47076cd8b4"
CROS_WORKON_TREE="57b1704c1c843e61f29d9c62203fe80169fd9a2e"
CROS_WORKON_PROJECT="chromiumos/platform/microbenchmarks"
CROS_WORKON_LOCALNAME="../platform/microbenchmarks"
inherit cros-workon

DESCRIPTION="Home for microbenchmarks designed in-house."
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/microbenchmarks/+/master"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

src_prepare() {
	cros-workon_src_prepare
}

src_compile() {
	cros-workon_src_compile
}

src_install() {
	cros-workon_src_install
	dobin "${OUT}"/memory-eater/memory-eater
}
