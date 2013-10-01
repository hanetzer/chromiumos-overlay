# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="598082622f05467f9b8be2f9430a3188b51c07ef"
CROS_WORKON_TREE="9659386c9107bfba61d69283d2751be9447df215"
CROS_WORKON_PROJECT="chromiumos/platform/power_manager"
CROS_WORKON_USE_VCSID="1"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-debug cros-workon eutils toolchain-funcs

DESCRIPTION="Power Manager for Chromium OS"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="-legacy_power_button test -lockvt -nocrit -is_desktop -als -mosys_eventlog"
IUSE="${IUSE} -asan -clang -has_keyboard_backlight -stay_awake_with_headphones -touch_device"
REQUIRED_USE="asan? ( clang )"

LIBCHROME_VERS="180609"

RDEPEND="chromeos-base/metrics
	chromeos-base/platform2
	dev-cpp/gflags
	dev-cpp/glog
	dev-libs/dbus-glib
	dev-libs/glib
	dev-libs/protobuf
	media-sound/adhd
	sys-fs/udev"

DEPEND="${RDEPEND}
	chromeos-base/libchrome:${LIBCHROME_VERS}[cros-debug=]
	chromeos-base/libchromeos
	chromeos-base/system_api
	test? ( dev-cpp/gmock )
	test? ( dev-cpp/gtest )"

src_prepare() {
	cros-workon_src_prepare
}

src_configure() {
	clang-setup-env
	cros-workon_src_configure

	export USE_ALS=$(usex als y "")
	export USE_HAS_KEYBOARD_BACKLIGHT=$(usex has_keyboard_backlight y "")
	export USE_IS_DESKTOP=$(usex is_desktop y "")
	export USE_LEGACY_POWER_BUTTON=$(usex legacy_power_button y "")
	export USE_LOCKVT=$(usex lockvt y "")
	export USE_MOSYS_EVENTLOG=$(usex mosys_eventlog y "")
	export USE_STAY_AWAKE_WITH_HEADPHONES=$(usex stay_awake_with_headphones y "")
	export USE_TOUCH_DEVICE=$(usex touch_device y "")
}

src_compile() {
	cros-workon_src_compile
}

src_test() {
	# Run tests if we're on x86
	if use arm ; then
		echo Skipping tests on non-x86 platform...
	else
		cros-workon_src_test
	fi
}

src_install() {
	cros-workon_src_install
	# Built binaries
	pushd "${OUT}" >/dev/null
	dobin powerd/powerd
	dobin powerd/powerd_setuid_helper
	dobin tools/backlight_dbus_tool
	dobin tools/backlight_tool
	dobin tools/get_powerd_initial_backlight_level
	dobin tools/memory_suspend_test
	dobin tools/powerd_dbus_suspend
	dobin tools/power_supply_info
	dobin tools/set_power_policy
	dobin tools/suspend_delay_sample
	popd >/dev/null

	fowners root:power /usr/bin/powerd_setuid_helper
	fperms 4750 /usr/bin/powerd_setuid_helper

	# Scripts
	dobin powerd/powerd_suspend
	dobin tools/activate_short_dark_resume
	dobin tools/debug_sleep_quickly
	dobin tools/send_metrics_on_resume
	dobin tools/set_short_powerd_timeouts
	dobin tools/suspend_stress_test

	insinto /usr/share/power_manager
	doins config/*

	insinto /etc/dbus-1/system.d
	doins dbus/org.chromium.PowerManager.conf

	# Install udev rule to set usb hid devices to wake the system.
	exeinto /lib/udev
	doexe udev/usb-hid-wake.sh

	insinto /lib/udev/rules.d
	doins udev/99-usb-hid-wake.rules

	# Nocrit disables low battery suspend percent by setting it to 0
	if use nocrit; then
		crit="usr/share/power_manager/low_battery_suspend_percent"
		if [ ! -e "${D}/${crit}" ]; then
			die "low_battery_suspend_percent config file missing"
		fi
		echo "0" > "${D}/${crit}"
	fi
}
