# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="fccd5f6e7494a938e08ab8aa677fb523c8289fb1"
CROS_WORKON_TREE="0d63f299826a0647674dea4e629db3c6e277e456"
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
