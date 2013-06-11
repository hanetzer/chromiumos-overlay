# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="fb5d00b6d252ac52085ccc192698d09ba2ec6ca6"
CROS_WORKON_TREE="7d50e37c522a493b9db08f9564178d4f58df6541"
CROS_WORKON_PROJECT="chromiumos/platform/mist"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-debug cros-workon

DESCRIPTION="Chromium OS Modem Interface Switching Tool"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="test"

LIBCHROME_VERS="180609"

RDEPEND="
	chromeos-base/libchrome:${LIBCHROME_VERS}[cros-debug=]
	chromeos-base/libchromeos
	dev-libs/protobuf
	sys-fs/udev
	virtual/libusb:1
"

DEPEND="
	${RDEPEND}
	test? ( dev-cpp/gmock )
	test? ( dev-cpp/gtest )
"

src_prepare() {
	cros-workon_src_prepare
}

src_configure() {
	cros-workon_src_configure
}

src_compile() {
	cros-workon_src_compile
}

src_test() {
	cros-workon_src_test
}

src_install() {
	cros-workon_src_install

	dobin "${OUT}"/mist
}
