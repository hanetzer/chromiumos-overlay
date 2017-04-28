# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="e5cf68cc592d2354973916b160b2e520bf804f33"
CROS_WORKON_TREE="5e3e9ee83e8dcc63caccb40d51ae3f3ee07fc19a"
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
