# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_LOCALNAME="firmware"
CROS_WORKON_PROJECT="chromiumos/platform/firmware"

# THIS IS A TEMPLATE EBUILD FILE.
# UNCOMMENT THE 'inherit' LINE TO ACTIVATE AND START YOUR MODIFICATION.

# inherit cros-workon cros-firmware

DESCRIPTION="Chrome OS Firmware (null template)"
# Empty (null) ebuild which satisifies virtual/chromeos-firmware.
# This is a direct dependency of chromeos-base/chromeos, but is expected to
# be overridden in an overlay for each specialized board.  A typical non-null
# implementation will install any board-specific configuration files and
# drivers which are not suitable for inclusion in a generic board overlay.

HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="~*"
IUSE=""

# The RDEPEND and description below should live in cros-firmware.eclass,
# and is only required here because this template does not inherit
# cros-firmware. Please remove this section when you're cloning this to
# a board overlay.
# Packages needed to unpack firmware updater (chromeos-firmware).
# The related packages will be included if chromeos-firmware package
# is enabled for a board. However, some new boards might be added
# to an early created factory branch without package chromeos-firmware.
# This will make unpacking firmware updater fail on the test image
# generated from the factor branch due to lack of those packages.
# Add them into test image to fix the failure.
# The contents of RDEPEND below must also be present in the
# chromeos-base/factory_installer ebuild in PROVIDED_DEPEND.
# If you make any change to the list below, you may need to make a
# matching change in the factory_installer ebuild.
RDEPEND="
	app-arch/gzip
	app-arch/sharutils
	app-arch/tar
	chromeos-base/vboot_reference
"

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

# If you need any additional resources in firmware update (ex,
# a customization script like "install_firmware_custom.sh"),
# put the filename or directory name here. Accepts multiple colon delimited
# values.
# Example: CROS_FIRMWARE_EXTRA_LIST="$FILESDIR/a_directory:$FILESDIR/a_file"
CROS_FIRMWARE_EXTRA_LIST=""
