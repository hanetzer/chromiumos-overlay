# Copyright (c) 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="dd5b5168293a497102c42f4ee4656ded6638cb00"
CROS_WORKON_TREE="d9cce70d25c6ef77164d8268cffff7aba0ca67df"
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
