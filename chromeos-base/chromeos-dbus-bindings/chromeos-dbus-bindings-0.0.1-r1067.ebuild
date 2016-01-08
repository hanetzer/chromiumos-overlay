# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT=("f6cf9ac6d0ff7ada322f310ecb594fe323b6322b" "4d7450f26396d6a5d3135e058873d484c3857aa0")
CROS_WORKON_TREE=("7dae0b54df35f300e201c2c9abe0d7ca87299de4" "84efcf8cbb9e56db9f9bbccc4491e0a5689bd3f1")
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
