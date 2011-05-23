# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_PROJECT="chromiumos/platform/firmware"

inherit cros-workon cros-firmware

DESCRIPTION="Chrome OS Firmware"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE=""

CROS_WORKON_LOCALNAME="firmware"

# ---------------------------------------------------------------------------
# CUSTOMIZATION SECTION

# Name of user account on the Binary Component Server.
CROS_FIRMWARE_BCS_USER_NAME=""

# System firmware image.
# Examples:
#  CROS_FIRMWARE_MAIN_IMAGE="bcs://filename.tbz2" - Fetch from Binary Component Server.
#  CROS_FIRMWARE_MAIN_IMAGE="file://filename.fd"  - Fetch from "files" directory.
#  CROS_FIRMWARE_MAIN_IMAGE="${ROOT}/lib/firmware/filename.fd" - Absolute file path.
CROS_FIRMWARE_MAIN_IMAGE=""

# EC (embedded controller) firmware.
# Examples:
#  CROS_FIRMWARE_EC_IMAGE="bcs://filename.tbz2" - Fetch from Binary Component Server.
#  CROS_FIRMWARE_EC_IMAGE="file://filename.bin" - Fetch from "files" directory.
#  CROS_FIRMWARE_EC_IMAGE="${ROOT}/lib/firmware/filename.bin" - Absolute file path.
CROS_FIRMWARE_EC_IMAGE=""

# EC (embedded controller) firmware image version identifier.
CROS_FIRMWARE_EC_VERSION=""

# If you need any additional resources in firmware update (ex,
# a customization script like "install_firmware_custom.sh"),
# put the filename or directory name here. Accepts multiple colon delimited
# values.
# Example: CROS_FIRMWARE_EXTRA_LIST="$FILESDIR/a_directory:$FILESDIR/a_file"
CROS_FIRMWARE_EXTRA_LIST=""
