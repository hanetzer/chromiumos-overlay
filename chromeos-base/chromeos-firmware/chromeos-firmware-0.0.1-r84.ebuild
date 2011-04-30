# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="63d99a5dc7ffc43e3cbedfa7ea97ce173dba39ef"

inherit cros-workon cros-firmware

DESCRIPTION="Chrome OS Firmware"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="arm x86"
IUSE=""

CROS_WORKON_LOCALNAME="firmware"
CROS_WORKON_PROJECT="firmware"

# ---------------------------------------------------------------------------
# CUSTOMIZATION SECTION

# Name of user account on the Binary Component Server.
CROS_FIRMWARE_BCS_USER_NAME=""

# BIOS firmware image archive.
# This archive should contain just the BIOS image file at its root.
CROS_FIRMWARE_BIOS_ARCHIVE=""

# BIOS firmware version identifier.
CROS_FIRMWARE_BIOS_VERSION=""

# EC (embedded controller) firmware archive.
# This archive should contain just the EC image file at its root.
CROS_FIRMWARE_EC_ARCHIVE=""

# EC (embedded controller) firmware image version identifier.
CROS_FIRMWARE_EC_VERSION=""

# If you need any additional resources in firmware update (ex,
# a customization script like "install_firmware_custom.sh"),
# put the filename or directory name here. Accepts multiple colon delimited
# values.
# Example: CROS_FIRMWARE_EXTRA_LIST="$FILESDIR/a_directory:$FILESDIR/a_file"
CROS_FIRMWARE_EXTRA_LIST=""
