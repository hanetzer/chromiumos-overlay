# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="0db2ba835b1b13855844bdd40618f7b365e67326"
CROS_WORKON_TREE="46d6b9ceb9ea2c31e60245ac55f9df605621c242"
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
