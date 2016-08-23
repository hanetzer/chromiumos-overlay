# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT=("9b086a29df8242700eb9335c5e8e0e0030c78e27" "bce0483dd09f592d6f9f989f0e34fc930d206810")
CROS_WORKON_TREE=("286e8bf5c4a24a3579e1366bcb274c660650ee81" "27e29c831e94f47231d247695852a3171d8fa38d")
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
