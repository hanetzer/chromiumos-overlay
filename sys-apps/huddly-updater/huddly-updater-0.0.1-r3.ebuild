# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="927748584ce871cdebe4ec076d0632ff91f45f87"
CROS_WORKON_TREE="70d2d1aba7d594c9b6eacfd359c820704e1aa97e"
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
