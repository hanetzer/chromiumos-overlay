# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

#
# Original Author: The Chromium OS Authors <chromium-os-dev@chromium.org>
# Purpose: Generate shell script containing firmware update bundle.
#

# @ECLASS-VARIABLE: CROS_FIRMWARE_BIOS_IMAGE
# @DESCRIPTION: (Optional) Location of system bios image
: ${CROS_FIRMWARE_BIOS_IMAGE:=}

# @ECLASS-VARIABLE: CROS_FIRMWARE_EC_IMAGE
# @DESCRIPTION: (Optional) Location of EC firmware image
: ${CROS_FIRMWARE_EC_IMAGE:=}

# @ECLASS-VARIABLE: CROS_FIRMWARE_IS_FORCE_UPDATE
# @DESCRIPTION: Force update whenever system runs chromeos-postinst
: ${CROS_FIRMWARE_IS_FORCE_UPDATE:=}

# @ECLASS-VARIABLE: CROS_FIRMWARE_BINARY
# @DESCRIPTION: (Optional) location of custom flashrom tool
: ${CROS_FIRMWARE_FLASHROM_BINARY:=}

# @ECLASS-VARIABLE: CROS_FIRMWARE_EXTRA_LIST
# @DESCRIPTION: (Optional) Colon separated list of addtional resources
: ${CROS_FIRMWARE_EXTRA_LIST:=}

# Some tools (flashrom, iotools, mosys, ...) were bundled in the updater so we
# don't write RDEPEND=$DEPEND. RDEPEND should have an explicit list of what it
# needs to extract and execute the updater.
DEPEND="x86? (
	sys-apps/flashrom
	sys-apps/iotools
	sys-apps/mosys )"

# TODO(hungte) remove gzip/tar if we have busybox
RDEPEND="
	app-arch/gzip
	app-arch/sharutils
	app-arch/tar "

# Check for EAPI 2 or 3
case "${EAPI:-0}" in
	3|2) ;;
	1|0|:) DEPEND="EAPI-UNSUPPORTED" ;;
esac

UPDATE_SCRIPT="chromeos-firmwareupdate"

cros-firmware_src_compile() {
	local image_cmd="" ext_cmd=""

	# prepare images
	if [ -n "$CROS_FIRMWARE_BIOS_IMAGE" ]; then
		image_cmd="$image_cmd -b $CROS_FIRMWARE_BIOS_IMAGE"
	fi
	if [ -n "$CROS_FIRMWARE_EC_IMAGE" ]; then
		image_cmd="$image_cmd -e $CROS_FIRMWARE_EC_IMAGE"
	fi

	# prepare extra commands
	if [ -n "$CROS_FIRMWARE_FLASHROM_BINARY" ]; then
		ext_cmd="$ext_cmd --flashrom $CROS_FIRMWARE_FLASHROM_BINARY"
	fi
	if [ -n "$CROS_FIRMWARE_EXTRA_LIST" ]; then
		ext_cmd="$ext_cmd --extra $CROS_FIRMWARE_EXTRA_LIST"
	fi

	# pack firmware update script!
	if [ -z "$image_cmd" ]; then
		# create an empty update script for the generic case
		# (no need to update)
		einfo "Building empty firmware update script"
		echo -n > ${UPDATE_SCRIPT}
	else
		# create a new script
		einfo "Building ${BOARD} firmware updater: $image_cmd $ext_cmd"
			"${WORKDIR}/${CROS_WORKON_LOCALNAME}"/pack_firmware.sh \
			-o ${UPDATE_SCRIPT} $image_cmd $ext_cmd \
			--tool_base="$ROOT/usr/sbin" || die "cannot pack firmware"
	fi
	chmod +x ${UPDATE_SCRIPT}
}

cros-firmware_src_install() {
	# install the main updater program
	dosbin $UPDATE_SCRIPT || die "failed to install update script"

	# install the "force firmware update" tag
	if [ "$CROS_FIRMWARE_IS_FORCE_UPDATE" -eq "1" ]; then
		einfo " *** ENABLED A FORCED FIRMWARE UPDATE *** "
		test -s "$UPDATE_SCRIPT" || einfo " WARNING: USING EMPTY FIRMWARE UPDATE."
		FORCE_UPDATE_DOT_FILE="${D}/.force_update_firmware"
		touch "${FORCE_UPDATE_DOT_FILE}"
		insinto /root
		doins "${FORCE_UPDATE_DOT_FILE}" \
			|| die "Cannot create tag for forced firmware update."
	fi
}

EXPORT_FUNCTIONS src_compile src_install
