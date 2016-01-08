# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT=("f6cf9ac6d0ff7ada322f310ecb594fe323b6322b" "d5eceb53b2b8b2ef5b0c4115ff1632b077201734")
CROS_WORKON_TREE=("7dae0b54df35f300e201c2c9abe0d7ca87299de4" "4b408ee605072f9c50b0cd34546e465c00864216")
CROS_WORKON_BLACKLIST=1
CROS_WORKON_LOCALNAME=("platform2" "aosp/system/connectivity/apmanager")
CROS_WORKON_PROJECT=("chromiumos/platform2" "platform/system/connectivity/apmanager")
CROS_WORKON_REPO=("https://chromium.googlesource.com" "https://android.googlesource.com")
CROS_WORKON_DESTDIR=("${S}/platform2" "${S}/aosp/system/connectivity/apmanager")
CROS_WORKON_INCREMENTAL_BUILD=1

PLATFORM_SUBDIR="apmanager"

inherit cros-workon platform user

DESCRIPTION="Access Point Manager for Chromium OS"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-Google"
SLOT=0
IUSE="test"
KEYWORDS="*"

RDEPEND="
	chromeos-base/chromeos-minijail
	chromeos-base/libbrillo
	chromeos-base/permission_broker
	net-dns/dnsmasq
	=net-wireless/hostapd-2.3
"

DEPEND="
	${RDEPEND}
	chromeos-base/permission_broker-client
	chromeos-base/shill
	test? (
		dev-cpp/gmock
		dev-cpp/gtest
	)
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
