# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"
CROS_WORKON_COMMIT="64e02c32d884c258fa6c0bd116da8a04ac1cd245"
CROS_WORKON_TREE="5fdf14e25dad2eba9b064ad6bbb5632e13b60f40"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
PLATFORM_SUBDIR="touch_keyboard"

inherit cros-workon platform user

DESCRIPTION="Touch Keyboard"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
IUSE="test"
KEYWORDS="*"

RDEPEND="chromeos-base/libbrillo"
DEPEND="test? ( dev-cpp/gmock dev-cpp/gtest )
	${RDEPEND}"

pkg_preinst() {
	# Set up the touch_keyboard user and group, which will be used to run
	# touch_keyboard_handler instead of root.
	enewuser touch_keyboard
	enewgroup touch_keyboard
}

src_install() {
	# Install the actual binary that handles the touch keyboard.
	dobin "${OUT}/touch_keyboard_handler"

	# Install a tool for testing the haptic feedback in the factory.
	dobin "${OUT}/touchkb_haptic_test"

	# Install an upstart script to start the handler at boot time.
	insinto "/etc/init"
	doins "touch_keyboard.conf"

	# Install the correct seccomp policy for this architecture.
	insinto "/opt/google/touch/policies"
	doins seccomp/${ARCH}/*.policy
}

platform_pkg_test() {
	platform_test "run" "${OUT}"/eventkey_test
	platform_test "run" "${OUT}"/slot_test
	platform_test "run" "${OUT}"/statemachine_test
	platform_test "run" "${OUT}"/evdevsource_test
	platform_test "run" "${OUT}"/uinputdevice_test
}
