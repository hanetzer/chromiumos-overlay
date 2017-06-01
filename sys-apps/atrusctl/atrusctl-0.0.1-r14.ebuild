# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="4301f27b8845f073ba4aa03bd8c38d53386915bb"
CROS_WORKON_TREE="b1cfd24704dd0dcb8ff6b5a788f6390f6b844d52"
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
