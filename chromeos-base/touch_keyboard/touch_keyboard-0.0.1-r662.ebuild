# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"
CROS_WORKON_COMMIT="184782774c44eb7debc99ed59899cc1ae2d9b22f"
CROS_WORKON_TREE="87ba049a63b6c7fd6d6f39575c0b1f1beaacdf89"
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
KEYWORDS="*"
IUSE=""

RDEPEND="chromeos-base/libbrillo"
DEPEND="${RDEPEND}"

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
