# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT=("6bee748cf8b210aa703963ccaa8ce99ecdcb65d5" "0f36410cec3fe0c95afa666f17198706c7669656")
CROS_WORKON_TREE=("a95adb63624935271f9e5adec66004fc76ee26db" "5ee6a646412b687cc623ef48edfde167ffb7b84a")
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
IUSE=""

RDEPEND="chromeos-base/libbrillo
	dev-libs/expat
	sys-apps/dbus"
DEPEND="${RDEPEND}"

src_install() {
	dobin "${OUT}"/generate-chromeos-dbus-bindings
}

platform_pkg_test() {
	platform_test "run" "${OUT}/chromeos_dbus_bindings_unittest"
}