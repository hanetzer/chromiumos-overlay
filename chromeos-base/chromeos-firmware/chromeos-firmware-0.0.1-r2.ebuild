# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

DESCRIPTION="Chrome OS Firmware"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="x86 arm"
IUSE=""

DEPEND=""

RDEPEND=""

UPDATE_SCRIPT="${D}/usr/sbin/chromeos-firmwareupdate"

src_install() {
	# Each OEM will have their own ebuild to overlay this file such that
	# they can specify their own shellball generation instruction.
	# An example:
	#   mkdir -p $(dirname ${UPDATE_SCRIPT})
	#   ${CHROMEOS_ROOT}/src/platform/pack_firmware.sh \
	#     -o ${UPDATE_SCRIPT} \
	#     -e ${EC_IMAGE} \
	#     -b ${BIOS_IMAGE} \
	#     --flashrom ${FLASHROM_BINARY} \
	#     --board $(basename ${ROOT})
	#
	# For x86-generic, we don't want to do a real firmware update, so just
	# create an empty firmware update script.
	mkdir -p $(dirname ${UPDATE_SCRIPT})
	touch ${UPDATE_SCRIPT}
	chmod +x ${UPDATE_SCRIPT}
}
