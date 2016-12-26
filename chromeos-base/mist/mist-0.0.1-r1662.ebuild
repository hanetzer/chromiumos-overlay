# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="950f71654d931ea3dfdd077e50d8e65337ac7e01"
CROS_WORKON_TREE="72f4fac0f5ead6e6bfb5a0b54e7fd3bb26ce8bc5"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="mist"

inherit cros-workon platform udev

DESCRIPTION="Chromium OS Modem Interface Switching Tool"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="test"

RDEPEND="
	chromeos-base/libbrillo
	chromeos-base/metrics
	dev-libs/protobuf
	net-dialup/ppp
	virtual/libusb:1
	virtual/udev
"

DEPEND="
	${RDEPEND}
	test? ( dev-cpp/gmock )
	dev-cpp/gtest
"

platform_pkg_test() {
	platform_test "run" "${OUT}/mist_testrunner"
}

src_install() {
	dobin "${OUT}"/mist

	insinto /usr/share/mist
	doins default.conf

	udev_dorules 51-mist.rules
}
