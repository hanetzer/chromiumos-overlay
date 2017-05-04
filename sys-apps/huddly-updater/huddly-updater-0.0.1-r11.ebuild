# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="b490de4edc6353b19a06787c654f3699777c6517"
CROS_WORKON_TREE="77bfe71b3d85e8360c8c12da4706d00115545aac"
CROS_WORKON_PROJECT="chromiumos/third_party/huddly-updater"

inherit cros-workon libchrome udev

DESCRIPTION="A utility to update Huddly camera firmware"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/third_party/huddly-updater"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

DEPEND="
	chromeos-base/libbrillo
	virtual/libusb:1
	virtual/libudev:0="

RDEPEND="${DEPEND}
	app-arch/unzip"

src_install() {
	dosbin huddly-updater
	udev_dorules conf/99-huddly.rules
}
