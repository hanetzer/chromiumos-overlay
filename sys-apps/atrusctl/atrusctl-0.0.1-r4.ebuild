# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="862532017d43ab68d3d69e8b2c92c858a3944b87"
CROS_WORKON_TREE="40c9813023a7a8ff9cda10831f0ac90145022de3"
CROS_WORKON_PROJECT="chromiumos/third_party/atrusctl"

inherit cros-workon cmake-utils udev user

DESCRIPTION="A tool to interact with an Atrus device from Chromium OS."
HOMEPAGE="http://www.limesaudio.com/"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"

DEPEND="virtual/libusb:1
	virtual/libudev:0="
RDEPEND="${DEPEND}"

src_install() {
	dosbin "${BUILD_DIR}/src/atrusctl"
	udev_newrules conf/udev-atrus.rules 99-atrus.rules
}

pkg_preinst() {
	enewuser atrus
	enewgroup atrus
}
