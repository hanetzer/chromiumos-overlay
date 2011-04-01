# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="1fe2de5d41d140e773d271a33bb4733440685941"

inherit cros-workon cros-firmware

DESCRIPTION="Chrome OS Firmware"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="arm x86"
IUSE=""

CROS_WORKON_LOCALNAME="firmware"
CROS_WORKON_PROJECT="firmware"

# ---------------------------------------------------------------------------
# CUSTOMIZATION SECTION

# Each OEM will have their own ebuild to overlay this file such that
# they can specify their own shellball generation instruction.

# It is suggested to put your firmware image files in "files/" folder
# and use "$FILESDIR" prefix to following path.

# Your BIOS firmware image file name.
# Example: CROS_FIRMWARE_BIOS_IMAGE="$FILESDIR/BIOS_0008.fd"
CROS_FIRMWARE_BIOS_IMAGE=""

# Your EC (embedded controller) firmware image file name.
# Example: CROS_FIRMWARE_EC_IMAGE="$FILESDIR/EC_0012.fd"
CROS_FIRMWARE_EC_IMAGE=""

# Change this to 1 if you REALLY want to update firmware whenever system
# invokes chromeos-postinst (for installation, recovery, and auto updates).
CROS_FIRMWARE_IS_FORCE_UPDATE=0

# If you need a special version of flashrom tool, put file name here.
# Example: CROS_FIRMWARE_FLASHROM_BINARY="$FILESDIR/flashrom.private"
CROS_FIRMWARE_FLASHROM_BINARY=""

# If you need any additional resources in firmware update (ex,
# a customization script like "install_firmware_custom.sh"),
# put the filename or directory name here. Accepts multiple colon delimited
# values.
# Example: CROS_FIRMWARE_EXTRA_LIST="$FILESDIR/a_directory:$FILESDIR/a_file"
CROS_FIRMWARE_EXTRA_LIST=""

# ---------------------------------------------------------------------------
