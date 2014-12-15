# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="c95cacaa4b52c6a8fdaa870d66d5eef5d67c7e05"
CROS_WORKON_TREE="6fa54d71960ae77852b01af726fc193d7ac979d8"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_DESTDIR="${S}/platform2"

PLATFORM_SUBDIR="firewalld"

inherit cros-workon platform

DESCRIPTION="System service for handling firewall rules in Chromium OS"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-Google"
SLOT=0
KEYWORDS="*"

RDEPEND="
	chromeos-base/libchromeos
	dev-libs/dbus-glib
	dev-libs/glib
	sys-apps/dbus
"

DEPEND="${RDEPEND}
	test? ( dev-cpp/gmock )
	dev-cpp/gtest
"

src_install() {
	dobin "${OUT}/firewalld"
}

platform_pkg_test() {
	local tests=(
		firewalld_unittest
	)

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done
}
