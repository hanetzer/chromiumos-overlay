# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_PROJECT="chromiumos/platform/power_manager"
CROS_WORKON_USE_VCSID="1"

inherit cros-debug cros-workon scons-utils toolchain-funcs

DESCRIPTION="Power Manager for Chromium OS"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE="-new_power_button test -lockvt -nocrit -is_desktop -als -aura"
IUSE="${IUSE} -has_keyboard_backlight"

LIBCHROME_VERS="125070"

RDEPEND="app-misc/ddccontrol
	chromeos-base/metrics
	dev-cpp/gflags
	dev-cpp/glog
	sys-fs/udev
	x11-base/xorg-server
	x11-libs/gtk+
	x11-libs/libX11
	x11-libs/libXext"

DEPEND="${RDEPEND}
	chromeos-base/libchrome:${LIBCHROME_VERS}[cros-debug=]
	chromeos-base/libchromeos
	chromeos-base/system_api
	test? ( dev-cpp/gmock )
	test? ( dev-cpp/gtest )
	test? ( x11-libs/libXtst )
	x11-proto/xextproto"

src_compile() {
	tc-export CC CXX AR RANLIB LD NM PKG_CONFIG
	cros-debug-add-NDEBUG
	export BASE_VER=${LIBCHROME_VERS}

	myesconsargs=(
		$(use_scons new_power_button)
		$(use_scons lockvt)
		$(use_scons is_desktop)
		$(use_scons als has_als)
		$(use_scons aura)
		$(use_scons has_keyboard_backlight)
	)
	escons || die "power_manager compile failed."
}

src_test() {
	tc-export CC CXX AR RANLIB LD NM PKG_CONFIG
	cros-debug-add-NDEBUG

	# Build tests
	myesconsargs=(
		$(use_scons new_power_button)
		$(use_scons lockvt)
		$(use_scons is_desktop)
		$(use_scons als has_als)
		$(use_scons aura)
		$(use_scons has_keyboard_backlight)
	)
	escons tests || die "tests compile failed."

	# Run tests if we're on x86
	if use arm ; then
		echo Skipping tests on non-x86 platform...
	else
		TESTS="backlight file_tagger power_supply powerd resolution_selector"
		TESTS="$TESTS state_control xidle";
		for ut in ${TESTS}; do
			"${S}/${ut}_unittest" \
				${GTEST_ARGS} || die "${ut}_unittest failed"
		done
	fi
}

src_install() {
	dobin "${S}/backlight-tool"
	dobin "${S}/backlight_dbus_tool"
	dobin "${S}/debug_sleep_quickly"
	dobin "${S}/power-supply-info"
	dobin "${S}/powerd"
	dobin "${S}/powerm"
	dobin "${S}/powerd_lock_screen"
	dobin "${S}/powerd_suspend"
	dobin "${S}/send_metrics_on_resume"
	dobin "${S}/power_state_tool"
	dobin "${S}/suspend_delay_sample"
	dobin "${S}/xidle-example"
	insinto "/usr/share/power_manager"
	for item in ${S}/config/*; do
		if [ $(basename "${item}") != "PRESUBMIT.cfg" ]; then
			doins "${item}"
		fi
	done
	insinto "/etc/dbus-1/system.d"
	doins "${S}/org.chromium.PowerManager.conf"

	# Install udev rule to set usb hid devices to wake the system.
	exeinto "/lib/udev"
	doexe "${S}/usb-hid-wake.sh"

	insinto "/lib/udev/rules.d"
	doins "${S}/99-usb-hid-wake.rules"

	# Nocrit disables low battery suspend percent by setting it to 0
	if use nocrit; then
		crit="usr/share/power_manager/low_battery_suspend_percent"
		if [ ! -e "${D}/${crit}" ]; then
			die "low_battery_suspend_percent config file missing"
		fi
		echo "0" > "${D}/${crit}"
	fi

	dodir /etc/dbus-1/system.d
	insinto /etc/dbus-1/system.d
	doins "${S}/RootPowerManager.conf"
}
