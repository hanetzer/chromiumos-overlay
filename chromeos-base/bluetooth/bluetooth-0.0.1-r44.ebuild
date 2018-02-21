# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="0fffbd8d7a75b563621629871d43b4d68f7388f7"
CROS_WORKON_TREE="6f86cd46d8b431142b5e0bcbd8c0aaa857957690"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_INCREMENTAL_BUILD=1

PLATFORM_SUBDIR="bluetooth"

inherit cros-workon platform

DESCRIPTION="Bluetooth service for Chromium OS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/bluetooth"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="seccomp"

RDEPEND="
	chromeos-base/libbrillo
	net-wireless/bluez"

DEPEND="${RDEPEND}
	chromeos-base/system_api"

src_install() {
	dobin "${OUT}"/newblued

	insinto /etc/init
	doins init/upstart/newblued.conf

	if use seccomp; then
		# Install seccomp policy files.
		insinto /usr/share/policy
		newins "seccomp_filters/newblued-seccomp-${ARCH}.policy" newblued-seccomp.policy
	else
		# Remove seccomp flags from minijail parameters.
		sed -i '/^env seccomp_flags=/s:=.*:="":' "${ED}"/etc/init/newblued.conf || die
	fi
}

platform_pkg_test() {
	platform_test "run" "${OUT}/newblued_test"
}