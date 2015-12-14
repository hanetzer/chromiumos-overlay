# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT=("065e3108172e42e727458079ad98fe903662ffca" "9f6fb89c67950128c98e723fad5263369f103faf")
CROS_WORKON_TREE=("eef67817c4dc2d13a86a751f6d2dbcc8a77a625b" "4c39ee7005d4a825cc91c2a49a7a0f113d2d0c26")
CROS_WORKON_BLACKLIST=1
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_DESTDIR=("${S}/platform2" "${S}/platform2/dbus-binding-generator")
CROS_WORKON_LOCALNAME=("platform2" "aosp/external/dbus-binding-generator")
CROS_WORKON_PROJECT=("chromiumos/platform2" "platform/external/dbus-binding-generator")
CROS_WORKON_REPO=("https://chromium.googlesource.com" "https://android.googlesource.com")

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
