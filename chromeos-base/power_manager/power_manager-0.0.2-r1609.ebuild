# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="0bb592bd40705d2cccfb0ee6ef0deac62c007623"
CROS_WORKON_TREE="5f9830ba0f7b2a6976d6274f164b493cf4a94c54"
CROS_WORKON_USE_VCSID="1"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_NATIVE_TEST="yes"
PLATFORM_SUBDIR="power_manager"

inherit cros-workon platform systemd udev user

DESCRIPTION="Power Manager for Chromium OS"
HOMEPAGE="http://dev.chromium.org/chromium-os/packages/power_manager"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="-als buffet +cras +display_backlight -has_keyboard_backlight -legacy_power_button -lockvt -mosys_eventlog -ozone systemd test"

RDEPEND="
	chromeos-base/metrics
	dev-libs/libnl
	dev-libs/protobuf
	cras? ( media-sound/adhd )
	virtual/udev"

DEPEND="${RDEPEND}
	chromeos-base/system_api
	test? ( dev-cpp/gmock )
	dev-cpp/gtest"

pkg_setup() {
	# Create the 'power' user and group here in pkg_setup as src_install needs
	# them to change the ownership of power manager files.
	enewuser "power"
	enewgroup "power"
	cros-workon_pkg_setup
}

src_install() {
	# Binaries for production
	dobin "${OUT}"/backlight_tool  # boot-splash, chromeos-boot-alert
	dobin "${OUT}"/dump_power_status  # crosh's battery_test command
	dobin "${OUT}"/powerd
	dobin "${OUT}"/powerd_setuid_helper
	dobin "${OUT}"/power_supply_info  # feedback
	dobin "${OUT}"/set_wifi_transmit_power
	fowners root:power /usr/bin/powerd_setuid_helper
	fperms 4750 /usr/bin/powerd_setuid_helper

	# Binaries for testing and debugging
	dobin "${OUT}"/backlight_dbus_tool
	dobin "${OUT}"/check_powerd_config
	dobin "${OUT}"/get_powerd_initial_backlight_level
	dobin "${OUT}"/memory_suspend_test
	dobin "${OUT}"/powerd_dbus_suspend
	dobin "${OUT}"/send_debug_power_status
	dobin "${OUT}"/set_power_policy
	dobin "${OUT}"/suspend_delay_sample

	# Scripts for production
	dobin powerd/powerd_suspend
	dobin tools/send_metrics_on_resume

	# Scripts for testing and debugging
	dobin tools/activate_short_dark_resume
	dobin tools/debug_sleep_quickly
	dobin tools/set_short_powerd_timeouts
	dobin tools/suspend_stress_test

	# Preferences
	insinto /usr/share/power_manager
	doins default_prefs/*
	use als && doins optional_prefs/has_ambient_light_sensor
	use cras && doins optional_prefs/use_cras
	use display_backlight || doins optional_prefs/external_display_only
	use has_keyboard_backlight && doins optional_prefs/has_keyboard_backlight
	use legacy_power_button && doins optional_prefs/legacy_power_button
	use lockvt && doins optional_prefs/lock_vt_before_suspend
	use mosys_eventlog && doins optional_prefs/mosys_eventlog
	use ozone || doins optional_prefs/check_active_vt

	insinto /etc/dbus-1/system.d
	doins dbus/org.chromium.PowerManager.conf

	exeinto "$(udev_get_udevdir)"
	doexe udev/*.sh

	udev_dorules udev/*.rules

	# Init scripts
	if use systemd; then
		systemd_dounit init/powerd.service
		systemd_enable_service boot-services.target powerd.service
		systemd_dounit init/report-power-metrics.service
		systemd_enable_service system-services.target report-power-metrics.service
		systemd_dotmpfilesd init/powerd_directories.conf
	else
		insinto /etc/init
		doins init/*.conf
	fi
	insinto /usr/share/cros/init
	doins init/powerd-pre-start.sh

	if use buffet; then
		# Buffet command handler definition
		insinto /etc/buffet/commands
		doins powerd/buffet/*.json
	fi
}

platform_pkg_test() {
	local tests=(
		power_manager_daemon_test
		power_manager_policy_test
		power_manager_system_test
		power_manager_util_test
	)

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done
}
