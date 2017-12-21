# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="33c56bf8da571234766daba07fcbb3ee5aaf7e8d"
CROS_WORKON_TREE="957797d1539da7c8c0584aa95c07863a2979b5d0"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="buffet"

inherit cros-workon libchrome platform user

DESCRIPTION="Local and cloud communication services for Chromium OS"
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD-Google"
SLOT=0
KEYWORDS="*"
IUSE="wifi_bootstrapping"

COMMON_DEPEND="
	chromeos-base/libbrillo
	chromeos-base/libweave
	wifi_bootstrapping? (
		chromeos-base/apmanager
		chromeos-base/peerd
		chromeos-base/webserver
	)
"

RDEPEND="
	${COMMON_DEPEND}
"

DEPEND="
	${COMMON_DEPEND}
	chromeos-base/shill-client
	chromeos-base/system_api
"

pkg_preinst() {
	# Create user and group for buffet.
	enewuser "buffet"
	enewgroup "buffet"
	# Additional groups to put buffet into.
	if use wifi_bootstrapping ; then
		enewgroup "apmanager"
		enewgroup "peerd"
	fi
}

src_install() {
	insinto "/usr/$(get_libdir)/pkgconfig"

	dobin "${OUT}"/buffet
	dobin "${OUT}"/buffet_client

	# DBus configuration.
	insinto /etc/dbus-1/system.d
	doins etc/dbus-1/org.chromium.Buffet.conf

	# Upstart script.
	insinto /etc/init
	doins etc/init/buffet.conf
	if ! use wifi_bootstrapping ; then
		sed -i 's/\(BUFFET_DISABLE_PRIVET=\).*$/\1true/g' \
			"${ED}"/etc/init/buffet.conf
	fi
}

platform_pkg_test() {
	local tests=(
		buffet_testrunner
	)

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done
}
