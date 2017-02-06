# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT=("412c2d769d909f0c1a39076c7de160f92a0214dd" "aefc886d79a17c983df42a462e3a32a9175a42a5")
CROS_WORKON_TREE=("efbbb7dd6a9744e29ddcbbf331de449b145aad56" "9c671b020b2d050fb75369d170b8a13dec7e72f6")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_DESTDIR=("${S}/platform2" "${S}/platform2/dbus-binding-generator")
CROS_WORKON_LOCALNAME=("platform2" "aosp/external/dbus-binding-generator")
CROS_WORKON_PROJECT=("chromiumos/platform2" "aosp/platform/external/dbus-binding-generator")

PLATFORM_SUBDIR="dbus-binding-generator/chromeos-dbus-bindings"
PLATFORM_GYP_FILE="chromeos-dbus-bindings.gyp"
PLATFORM_NATIVE_TEST="yes"

inherit cros-workon platform

DESCRIPTION="Utility for building Chrome D-Bus bindings from an XML description"
HOMEPAGE="http://dev.chromium.org/chromium-os/platform"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="test"

RDEPEND="chromeos-base/libbrillo
	dev-libs/expat
	sys-apps/dbus"
DEPEND="
	${RDEPEND}
	dev-cpp/gtest
	test? (
		dev-cpp/gmock
	)
"

src_install() {
	dobin "${OUT}"/generate-chromeos-dbus-bindings
}

platform_pkg_test() {
	platform_test "run" "${OUT}/chromeos_dbus_bindings_unittest"
}
