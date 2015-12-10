# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="0801b39b9fbc09ad703644c6e9d5f38ef459704f"
CROS_WORKON_TREE="6b107680fe5a8d19b79ad0b2c13f5fca65f5fe01"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_USE_VCSID=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="easy-unlock"

inherit cros-workon platform user

DESCRIPTION="Service for supporting Easy Unlock in Chromium OS"
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="test"

RDEPEND="
	chromeos-base/easy-unlock-crypto
	chromeos-base/libbrillo
"

DEPEND="
	${RDEPEND}
	chromeos-base/system_api
	dev-cpp/gtest
	test? (
		dev-cpp/gmock
	)
"

pkg_preinst() {
	enewuser easy-unlock
	enewgroup easy-unlock
}

src_install() {
	exeinto /opt/google/easy_unlock
	doexe "${OUT}/easy_unlock"

	insinto /etc/dbus-1/system.d
	doins org.chromium.EasyUnlock.conf

	insinto /usr/share/dbus-1/system-services
	doins org.chromium.EasyUnlock.service

	insinto /usr/share/dbus-1/interfaces
	doins dbus_bindings/org.chromium.EasyUnlockInterface.xml
}

platform_pkg_test() {
	platform_test "run" "${OUT}/easy_unlock_test_runner"
}
