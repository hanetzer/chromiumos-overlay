# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="c5395f1d8392ae8e050e9f8c952be12c7553b33f"
CROS_WORKON_TREE="c06e0dc0a0473601c2d9f6a67de79560dfb5e44f"
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
