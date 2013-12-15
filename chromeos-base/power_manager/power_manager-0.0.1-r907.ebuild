# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="5f4ea694baee4b339d8f84d08aa282da3e7e0439"
CROS_WORKON_TREE="82b5aee36e04405967bbb4c7d64ca05928648e9f"
CROS_WORKON_PROJECT="chromiumos/platform/power_manager"
CROS_WORKON_USE_VCSID="1"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-debug cros-workon eutils toolchain-funcs

DESCRIPTION="Power Manager for Chromium OS"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"
IUSE="-legacy_power_button test -lockvt -is_desktop -als -mosys_eventlog"
IUSE="${IUSE} -asan -clang -has_keyboard_backlight"
REQUIRED_USE="asan? ( clang )"

LIBCHROME_VERS="180609"

RDEPEND="chromeos-base/platform2
	dev-cpp/gflags
	dev-cpp/glog
	dev-libs/dbus-glib
	dev-libs/glib
	dev-libs/protobuf
	media-sound/adhd
	sys-fs/udev"

DEPEND="${RDEPEND}
	chromeos-base/libchrome:${LIBCHROME_VERS}[cros-debug=]
	test? ( dev-cpp/gmock )
	test? ( dev-cpp/gtest )"

src_prepare() {
	cros-workon_src_prepare
}

src_configure() {
	clang-setup-env
	cros-workon_src_configure
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

	# Preferences
	insinto /usr/share/power_manager
	doins default_prefs/*
	use als && doins optional_prefs/has_ambient_light_sensor
	use has_keyboard_backlight && doins optional_prefs/has_keyboard_backlight
	use is_desktop && doins optional_prefs/external_display_only
	use legacy_power_button && doins optional_prefs/legacy_power_button
	use lockvt && doins optional_prefs/lock_vt_before_suspend
	use mosys_eventlog && doins optional_prefs/mosys_eventlog

	insinto /etc/dbus-1/system.d
	doins dbus/org.chromium.PowerManager.conf

	# Install udev rule to set usb hid devices to wake the system.
	exeinto /lib/udev
	doexe udev/usb-hid-wake.sh
	doexe udev/usb-persistence-enable.sh

	insinto /lib/udev/rules.d
	doins udev/99-usb-hid-wake.rules
	doins udev/99-usb-persistence-enable.rules
}
