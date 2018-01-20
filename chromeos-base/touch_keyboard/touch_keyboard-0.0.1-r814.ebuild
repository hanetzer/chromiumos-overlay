# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"
CROS_WORKON_COMMIT="09f466434cdc8f4182df9405612b2e211393cabe"
CROS_WORKON_TREE="891a08d264d364bc822b93141a15898ca41cbc35"
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
