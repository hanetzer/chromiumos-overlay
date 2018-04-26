# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT=("bdc5c6460b32da5d025a4e2a019a8ea7210c4f82" "367bdb38f60fdfe76814c8cf9f383ff8d6f5b484")
CROS_WORKON_TREE=("94a1336ddfc584b23df58564be093463f801d558" "dc3351025959287acf11482ee54e9264e4c8ad66")
CROS_WORKON_LOCALNAME=("platform2" "aosp/system/connectivity/apmanager")
CROS_WORKON_PROJECT=("chromiumos/platform2" "aosp/platform/system/connectivity/apmanager")
CROS_WORKON_DESTDIR=("${S}/platform2" "${S}/aosp/system/connectivity/apmanager")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_SUBTREE=("common-mk" "")

PLATFORM_SUBDIR="apmanager"

inherit cros-workon platform user

DESCRIPTION="Access Point Manager for Chromium OS"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="
	chromeos-base/minijail
	chromeos-base/libbrillo
	chromeos-base/permission_broker
	net-dns/dnsmasq
	net-wireless/hostapd
"

DEPEND="
	${RDEPEND}
	chromeos-base/permission_broker-client
	chromeos-base/shill
"

src_unpack() {
	local s="${S}"
	platform_src_unpack
	S="${s}/aosp/system/connectivity/apmanager"
}

src_install() {
	dobin "${OUT}"/apmanager
	# Install init scripts.
	insinto /etc/init
	doins init/apmanager.conf

	# DBus configuration.
	insinto /etc/dbus-1/system.d
	doins dbus_permissions/org.chromium.apmanager.conf

	# Install DBus client library.
	platform_install_dbus_client_lib

	# Install seccomp file.
	insinto /usr/share/policy
	newins init/apmanager-seccomp-${ARCH}.policy apmanager-seccomp.policy
}

pkg_preinst() {
	# Create user and group for apmanager.
	enewuser "apmanager"
	enewgroup "apmanager"
}

platform_pkg_test() {
	local tests=(
		apmanager_testrunner
	)

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done
}
