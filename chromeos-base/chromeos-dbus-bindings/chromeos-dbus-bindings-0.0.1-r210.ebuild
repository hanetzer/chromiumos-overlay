# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT="499b0eb4f23db2d7060c5e69b60565bd39baeb8e"
CROS_WORKON_TREE="731269e5c24c19c16b9aa0b33f763b32aa744908"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="chromeos-dbus-bindings"
PLATFORM_NATIVE_TEST="yes"

inherit cros-workon platform

DESCRIPTION="Utility for building Chrome D-Bus bindings from an XML description"
HOMEPAGE="http://dev.chromium.org/chromium-os/platform"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="test"

RDEPEND="chromeos-base/libchromeos
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
