# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT=("7c6a07946078fa2604559ee66f5d97950a73301e" "1b8aaa412109299d178536411989d7226e940e8e")
CROS_WORKON_TREE=("91aefeee8b7542a2f411eb3a1dcada7a93351ea8" "08c84cbcbcf1fbeee2f76d45d68a2bdb4e50c11c")
inherit cros-constants

CROS_WORKON_INCREMENTAL_BUILD="1"
CROS_WORKON_PROJECT=("chromiumos/platform2" "chromiumos/platform/cfm-device-monitor")
CROS_WORKON_LOCALNAME=("../platform2" "../platform/cfm-device-monitor")
CROS_WORKON_DESTDIR=("${S}/platform2" "${S}/platform/cfm-device-monitor")
CROS_WORKON_REPO=("${CROS_GIT_HOST_URL}" "${CROS_GIT_HOST_URL}")

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
	insinto "/etc/dbus-1/system.d"
	doins dbus/org.chromium.huddlymonitor.conf
	insinto "/etc/init"
	doins init/huddly-monitor.conf
	udev_dorules conf/99-huddly-monitor.rules
	dobin conf/huddlymonitor_update
}

platform_pkg_test(){
	platform_test "run" "${OUT}/camera-monitor-test"
}

pkg_preinst() {
	enewuser cfm-monitor
	enewgroup cfm-monitor
}
