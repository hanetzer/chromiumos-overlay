# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="340542b21c30cd62a68d19f086edef36d849971b"
CROS_WORKON_TREE="cae122ce8c6126141c298516d0575a067a9efe7d"
CROS_WORKON_PROJECT="chromiumos/third_party/toolchain-utils"
CROS_WORKON_LOCALNAME="toolchain-utils"

inherit cros-workon

DESCRIPTION="Compilation and runtime tests for toolchain"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-Google"
SLOT=0
KEYWORDS="*"
IUSE=""

RDEPEND="
	app-misc/pax-utils
	dev-lang/python
	sys-devel/binutils
"

src_install() {
	local tc_dir="/usr/$(get_libdir)/${PN}"
	local dit_dir="${tc_dir}/debug_info_test"

	insinto ${tc_dir}
	doins -r debug_info_test

	fperms a+x ${dit_dir}/debug_info_test.py

	dosym ${dit_dir}/debug_info_test.py /usr/bin/debug_info_test
}
