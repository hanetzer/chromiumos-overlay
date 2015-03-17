# Copyright (c) 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="389e1f3cacb1bd81cd4494f87b1cfe91e22cefb3"
CROS_WORKON_TREE="8b4b96b16eacb3bd2ac0374c3fc40e7031f00883"
CROS_WORKON_PROJECT="chromiumos/platform/touch_firmware_test"

inherit cros-workon cros-constants cros-debug

DESCRIPTION="Chromium OS multitouch utilities"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="-asan -clang"
REQUIRED_USE="asan? ( clang )"

RDEPEND=""

DEPEND=${RDEPEND}

src_prepare() {
	cros-workon_src_prepare
}

src_configure() {
	cros-workon_src_configure
}

src_install() {
	# install to autotest deps directory for dependency
	DESTDIR="${D}${AUTOTEST_BASE}/client/deps/touchpad-tests/touch_firmware_test"
	mkdir -p "${DESTDIR}"
	echo "CMD:" cp -Rp "${S}"/* "${DESTDIR}"
	cp -Rp "${S}"/* "${DESTDIR}"
}
