# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT=("5a8bd69a1afd18db83e57d7e2cec5e419e61f34a" "90da20d20ed3200c47221757b9bfe0aeb3a127a9")
CROS_WORKON_TREE=("84a565694177945737ea416ba1416a17d0733978" "dd9bea9985ef31db1a0ce4879e8dbba0f32899bf")
inherit cros-constants

CROS_WORKON_INCREMENTAL_BUILD="1"
CROS_WORKON_PROJECT=("chromiumos/platform2" "chromiumos/platform/cfm-device-monitor")
CROS_WORKON_LOCALNAME=("../platform2" "../platform/cfm-device-monitor")
CROS_WORKON_DESTDIR=("${S}/platform2" "${S}/platform/cfm-device-monitor")
CROS_WORKON_REPO=("${CROS_GIT_HOST_URL}" "${CROS_GIT_HOST_URL}")

PLATFORM_SUBDIR="cfm-device-monitor"

inherit cros-workon platform udev

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
}

platform_pkg_test(){
	platform_test "run" "${OUT}/camera-monitor-test"
}
