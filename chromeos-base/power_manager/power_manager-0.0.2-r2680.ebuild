# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="10288dd376e6ce321187dfa3b8ef5c87fe986d9f"
CROS_WORKON_TREE=("903136741a0802ef6d2c7cf4820a19218646f7ec" "0189c3d12577d8cc2dae54c2d254ed77f4d36b66" "bdfdfd8aaf61a4a5da27aae7308c8326d30f10ed" "f151afc2e5241eeb2ae52d3c83d124e1f0dcc836" "2f0635e921bc38819d1c6b1d00e055048e85ef7b")
CROS_WORKON_USE_VCSID="1"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
# TODO(crbug.com/809389): Avoid directly including headers from other packages.
CROS_WORKON_SUBTREE="common-mk buffet chromeos-config metrics power_manager"
CROS_BOARDS=(kip)

PLATFORM_NATIVE_TEST="yes"
PLATFORM_SUBDIR="power_manager"

inherit cros-board cros-workon platform systemd udev user

DESCRIPTION="Power Manager for Chromium OS"
HOMEPAGE="http://dev.chromium.org/chromium-os/packages/power_manager"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="-als buffet cellular +cras cros_embedded +display_backlight -has_keyboard_backlight -keyboard_includes_side_buttons -legacy_power_button -mosys_eventlog +powerknobs systemd +touchpad_wakeup -touchscreen_wakeup unibuild"

RDEPEND="
	cellular? (
		board_use_kip? ( chromeos-base/ec-utils )
	)
	unibuild? ( chromeos-base/chromeos-config )
	chromeos-base/chromeos-config-tools
	chromeos-base/metrics
	dev-libs/libnl
	dev-libs/protobuf
	cras? ( media-sound/adhd )
	virtual/udev"

# blocker (https://crbug.com/214886), can be removed later
RDEPEND+="
	 !app-laptop/laptop-mode-tools
"

DEPEND="${RDEPEND}
	chromeos-base/system_api"

# Some deps we only need at runtime.
RDEPEND+="
	mosys_eventlog? ( sys-apps/mosys )
"

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
	dobin "${OUT}"/check_powerd_config
	use amd64 && dobin "${OUT}"/dump_intel_rapl_consumption
	dobin "${OUT}"/inject_powerd_input_event
	dobin "${OUT}"/memory_suspend_test
	dobin "${OUT}"/powerd_dbus_suspend
	dobin "${OUT}"/send_debug_power_status
	dobin "${OUT}"/set_power_policy
	dobin "${OUT}"/suspend_delay_sample

	# Scripts for production
	dobin powerd/powerd_suspend
	dobin tools/cpufreq_config
	dobin tools/print_sysfs_power_supply_data  # feedback
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
	use mosys_eventlog && doins optional_prefs/mosys_eventlog

	insinto /etc/dbus-1/system.d
	doins dbus/org.chromium.PowerManager.conf

	# udev scripts and rules.
	exeinto "$(get_udevdir)"
	doexe udev/*.sh
	udev_dorules udev/*.rules

	if use powerknobs; then
		udev/gen_autosuspend_rules.py > "${T}"/98-autosuspend.rules || die
		udev_dorules "${T}"/98-autosuspend.rules
		udev_dorules udev/optional/98-powerknobs.rules
		dobin udev/optional/set_blkdev_pm
	fi
	if use keyboard_includes_side_buttons; then
		udev_dorules udev/optional/93-powerd-tags-keyboard-side-buttons.rules
	fi
	if ! use touchpad_wakeup; then
		udev_dorules udev/optional/93-powerd-tags-no-touchpad-wakeup.rules
	fi
	if use touchscreen_wakeup; then
		udev_dorules udev/optional/93-powerd-tags-touchscreen-wakeup.rules
	fi

	# Init scripts
	if use systemd; then
		systemd_dounit init/systemd/*.service
		systemd_enable_service boot-services.target powerd.service
		systemd_enable_service system-services.target report-power-metrics.service
		systemd_dotmpfilesd init/systemd/powerd_directories.conf
	else
		insinto /etc/init
		doins init/upstart/*.conf
	fi
	insinto /usr/share/cros/init
	doins init/shared/powerd-pre-start.sh

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