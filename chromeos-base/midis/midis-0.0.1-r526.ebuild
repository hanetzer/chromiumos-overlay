# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="a84c9bc3199f620ae2830a9932d9f706f8974778"
CROS_WORKON_TREE="b295bf5defd0a842f7a740b38b751de600029b85"
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

	# Install libraries
	./platform2_preinstall.sh "${OUT}"
	dolib.a "${OUT}"/libmidis.a
	insinto "/usr/$(get_libdir)/pkgconfig"
	doins "${OUT}"/obj/midis/libmidis.pc

	# Install headers
	insinto /usr/include/midis/
	doins libmidis/clientlib.h

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
