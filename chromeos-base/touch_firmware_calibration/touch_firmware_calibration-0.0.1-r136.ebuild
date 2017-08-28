# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"
CROS_WORKON_COMMIT="a10d3cd43e95155201899e7b28c5c2dc067afe96"
CROS_WORKON_TREE="d6282b3b3d85e18c42e704011e9c6da1155ce6f8"
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
