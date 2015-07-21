# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="eea56c9f7073f56e09dad8ea22ce3861c5c8fe44"
CROS_WORKON_TREE="168a3d9c5b9aa5696afedb93601fb63b5ba548e8"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="firewalld"

inherit cros-workon platform

DESCRIPTION="System service for handling firewall rules in Chromium OS"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-Google"
SLOT=0
KEYWORDS="*"

RDEPEND="
	chromeos-base/chromeos-minijail
	chromeos-base/libchromeos
	sys-apps/dbus
"

DEPEND="${RDEPEND}
	chromeos-base/system_api
	test? ( dev-cpp/gmock )
	dev-cpp/gtest
"

src_install() {
	dobin "${OUT}/firewalld"

	# Install D-Bus configuration.
	insinto /etc/dbus-1/system.d
	doins dbus/org.chromium.Firewalld.conf

	# Install Upstart configuration.
	insinto /etc/init
	doins firewalld.conf
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
