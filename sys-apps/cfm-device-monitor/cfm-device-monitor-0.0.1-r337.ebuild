# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT=("5f886f904ccc6e3471d2f39b4f73d0f4eb916a6c" "5e5d0d76ce31842c0c4b53d022d6824b088d4b79")
CROS_WORKON_TREE=("99d4f98c0151c7e25437bb625f114bde347170d5" "3bf0fc0014f3737a65b27e89e2c0a2fbc4e6cb10")
inherit cros-constants

CROS_WORKON_INCREMENTAL_BUILD="1"
CROS_WORKON_PROJECT=("chromiumos/platform2" "chromiumos/platform/cfm-device-monitor")
CROS_WORKON_LOCALNAME=("../platform2" "../platform/cfm-device-monitor")
CROS_WORKON_DESTDIR=("${S}/platform2" "${S}/platform/cfm-device-monitor")
CROS_WORKON_REPO=("${CROS_GIT_HOST_URL}" "${CROS_GIT_HOST_URL}")
CROS_WORKON_SUBTREE=("common-mk" "")

PLATFORM_SUBDIR="cfm-device-monitor"

inherit cros-workon platform udev user

DESCRIPTION="A monitoring service that ensures liveness of cfm peripherals"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/cfm-device-monitor"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

DEPEND="chromeos-base/libbrillo"

RDEPEND="${DEPEND}"

src_unpack() {
	local s="${S}"
	platform_src_unpack
	S="${s}/platform/cfm-device-monitor"
}

src_install() {
	dosbin "${OUT}"/huddly-monitor
	dosbin "${OUT}"/mimo-monitor
	insinto "/etc/dbus-1/system.d"
	doins dbus/org.chromium.huddlymonitor.conf
	insinto "/etc/init"
	doins init/huddly-monitor.conf
	doins init/mimo-monitor.conf
	udev_dorules conf/99-huddly-monitor.rules
	udev_dorules conf/99-mimo-monitor.rules
	dobin conf/huddlymonitor_update
}

platform_pkg_test(){
	platform_test "run" "${OUT}/camera-monitor-test"
}

pkg_preinst() {
	enewuser cfm-monitor
	enewgroup cfm-monitor
	enewgroup cfm-peripherals
}
