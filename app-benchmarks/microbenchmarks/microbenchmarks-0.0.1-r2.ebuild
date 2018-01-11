# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

CROS_WORKON_COMMIT="518003bc070970f25b9ab97c0560d762846c5e65"
CROS_WORKON_TREE="78ab60cace2eabca9fd0eab96be2327cc6231ea7"
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
