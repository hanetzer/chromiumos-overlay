# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"
CROS_WORKON_COMMIT="e69bdbb698f1c863e723fef99202af590005fd6c"
CROS_WORKON_TREE="54d775ec65dc6be5adb9b99fdfa4c04607c0d440"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_OUTOFTREE_BUILD=1
PLATFORM_SUBDIR="touch_firmware_calibration"

inherit cros-workon platform user udev

DESCRIPTION="Touch Firmware Calibration"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/touch_firmware_calibration/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="chromeos-base/libbrillo"
DEPEND="${RDEPEND}"

pkg_preinst() {
	# Set up touch_firmware_calibration user and group which will be used to
	# run tools for calibration.
	enewuser touch_firmware_calibration
	enewgroup touch_firmware_calibration
}

src_install() {
	# Install a tool to override max pressure.
	exeinto "$(udev_get_udevdir)"
	doexe "${OUT}/override-max-pressure"

	# Install the correct seccomp policy for this architecture.
	insinto "/usr/share/policy"
	newins "seccomp/override-max-pressure-seccomp-${ARCH}.policy" override-max-pressure-seccomp.policy
}
