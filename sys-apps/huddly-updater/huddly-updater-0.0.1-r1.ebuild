# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="aeb883ad18a2d427e754ea70801e3f5f0ad05570"
CROS_WORKON_TREE="b5b7f173ec8932c413cfa589dcef4fb01b9570b8"
CROS_WORKON_PROJECT="chromiumos/third_party/huddly-updater"

inherit cros-workon udev

DESCRIPTION="A utility to update Huddly camera firmware"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/third_party/huddly-updater"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

DEPEND="
	virtual/libusb:1
	virtual/libudev:0="

RDEPEND="${DEPEND}"

src_install() {
	dosbin huddly-updater
	udev_dorules conf/99-huddly.rules
}
