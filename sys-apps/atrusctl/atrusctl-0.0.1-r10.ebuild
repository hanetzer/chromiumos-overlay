# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="b2e16c9528b581ffa36959101d5ec4565a2139a7"
CROS_WORKON_TREE="0b409e0ddc3f7bf71ed275259609035ae68e87f2"
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
	insinto /etc/rsyslog.d
	newins conf/rsyslog-atrus.conf atrus.conf
}

pkg_preinst() {
	enewuser atrus
	enewgroup atrus
}