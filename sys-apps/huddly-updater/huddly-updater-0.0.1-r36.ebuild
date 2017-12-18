# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="eeb79ce39812a393bba8c5e888e3c25f4b30334d"
CROS_WORKON_TREE="92053ba7e73f406883810f7422155a54de60cd98"
CROS_WORKON_PROJECT="chromiumos/third_party/huddly-updater"

inherit cros-workon libchrome udev user

DESCRIPTION="A utility to update Huddly camera firmware"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/third_party/huddly-updater"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="test"

DEPEND="
	chromeos-base/libbrillo
	test? ( dev-cpp/gtest )
	virtual/libusb:1
	virtual/libudev:0="

RDEPEND="${DEPEND}
	app-arch/unzip"

src_configure() {
	cros-workon_src_configure
}

src_test() {
	if use amd64; then
		emake tests
	fi
}

src_install() {
	dosbin huddly-updater
	dosbin huddly-manifest
	udev_dorules conf/99-huddly.rules
}

pkg_preinst() {
	enewuser cfm-firmware-updaters
	enewgroup cfm-firmware-updaters
}
