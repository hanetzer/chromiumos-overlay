# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="57ac7b0dd771f31db0c542743fd34e6d4d22b4af"
CROS_WORKON_TREE="cae0e053d6e37f16d9bf680e2c9fc4953cd8e2d8"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="midis"

inherit cros-workon platform user multilib

DESCRIPTION="MIDI Server for Chromium OS"
HOMEPAGE=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="+seccomp"

src_install() {
	dobin "${OUT}"/midis

	insinto /etc/init
	doins init/*.conf

	# Install midis DBUS configuration file
	insinto /etc/dbus-1/system.d
	doins dbus_permissions/org.chromium.Midis.conf

	# Install seccomp policy file.
	insinto /usr/share/policy
	use seccomp && newins "seccomp/midis-seccomp-${ARCH}.policy" midis-seccomp.policy
}

pkg_preinst() {
	enewuser midis
	enewgroup midis
}

platform_pkg_test() {
	local tests=(
		"midis_testrunner"
	)

	local test
	for test in "${tests[@]}"; do
		platform_test "run" "${OUT}"/${test}
	done
}
