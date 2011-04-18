# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
#
# Original Author: The Chromium OS Authors <chromium-os-dev@chromium.org>
# Purpose: Generate shell script containing firmware update bundle.
#

inherit cros-workon cros-binary

CROS_WORKON_LOCALNAME="firmware"
CROS_WORKON_PROJECT="firmware"

# @ECLASS-VARIABLE: CROS_FIRMWARE_BCS_USER_NAME
# @DESCRIPTION: (Optional) Name of user on BCS server
: ${CROS_FIRMWARE_BCS_USER_NAME:=}

# @ECLASS-VARIABLE: CROS_FIRMWARE_BIOS_ARCHIVE
# @DESCRIPTION: (Optional) Location of system bios image
: ${CROS_FIRMWARE_BIOS_ARCHIVE:=}

# @ECLASS-VARIABLE: CROS_FIRMWARE_BIOS_VERSION
# @DESCRIPTION: (Optional) Version name of BIOS
: ${CROS_FIRMWARE_BIOS_VERSION:="IGNORE"}

# @ECLASS-VARIABLE: CROS_FIRMWARE_EC_ARCHIVE
# @DESCRIPTION: (Optional) Location of EC firmware image
: ${CROS_FIRMWARE_EC_ARCHIVE:=}

# @ECLASS-VARIABLE: CROS_FIRMWARE_EC_VERSION
# @DESCRIPTION: (Optional) Version name of EC
: ${CROS_FIRMWARE_EC_VERSION:="IGNORE"}

# @ECLASS-VARIABLE: CROS_FIRMWARE_BINARY
# @DESCRIPTION: (Optional) location of custom flashrom tool
: ${CROS_FIRMWARE_FLASHROM_BINARY:=}

# @ECLASS-VARIABLE: CROS_FIRMWARE_EXTRA_LIST
# @DESCRIPTION: (Optional) Colon separated list of addtional resources
: ${CROS_FIRMWARE_EXTRA_LIST:=}

# Some tools (flashrom, iotools, mosys, ...) were bundled in the updater so we
# don't write RDEPEND=$DEPEND. RDEPEND should have an explicit list of what it
# needs to extract and execute the updater.
DEPEND="
	>=sys-apps/flashrom-0.9.3-r36
	>=chromeos-base/vboot_reference-1.0-r230
	x86? ( sys-apps/mosys )
	"

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

cros-firmware_src_unpack() {
	cros-workon_src_unpack

	mkdir -p "${S}" || die "Not able to create ${S}"
	cd "${S}" || die "Can't change directory to ${S}"

	URI_BASE="ssh://${CROS_FIRMWARE_BCS_USER_NAME}@git.chromium.org:6222"\
"${URI_BASE}/home/${CROS_FIRMWARE_BCS_USER_NAME}/${CATEGORY}/${PN}"

	# Fetch and unpack the BIOS image
	if [ -n "$CROS_FIRMWARE_BIOS_ARCHIVE" ]; then
		CROS_BINARY_URI="${URI_BASE}/${CROS_FIRMWARE_BIOS_ARCHIVE}"
		cros-binary_fetch
		cp "${CROS_BINARY_STORE_DIR}/${CROS_FIRMWARE_BIOS_ARCHIVE}" "${S}"
		tar jxpf "${CROS_FIRMWARE_BIOS_ARCHIVE}" || die "Failed to unpack"
	fi

	# Fetch and unpack the EC image
	if [ -n "$CROS_FIRMWARE_EC_ARCHIVE" ]; then
		CROS_BINARY_URI="${URI_BASE}/${CROS_FIRMWARE_EC_ARCHIVE}"
		cros-binary_fetch
		cp "${CROS_BINARY_STORE_DIR}/${CROS_FIRMWARE_EC_ARCHIVE}" "${S}"
		tar jxpf "${CROS_FIRMWARE_EC_ARCHIVE}" || die "Failed to unpack"
	fi
}

cros-firmware_src_compile() {
	local image_cmd="" ext_cmd=""
	local bios_image="" ec_image=""

	pushd "${S}" || die "Can't change directory to ${S}"
	if [ -n "$CROS_FIRMWARE_BIOS_ARCHIVE" ]; then
		bios_image="$(tar tf ${CROS_FIRMWARE_BIOS_ARCHIVE})"
	fi
	if [ -n "$CROS_FIRMWARE_EC_ARCHIVE" ]; then
		ec_image="$(tar tf ${CROS_FIRMWARE_EC_ARCHIVE})"
	fi
	popd

	# prepare images
	if [ -n "$bios_image" ]; then
		image_cmd="$image_cmd -b $bios_image"
	fi
	if [ -n "$ec_image" ]; then
		image_cmd="$image_cmd -e $ec_image"
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
			--bios_version "${CROS_FIRMWARE_BIOS_VERSION}" \
			--ec_version "${CROS_FIRMWARE_EC_VERSION}" \
			-o ${UPDATE_SCRIPT} $image_cmd $ext_cmd \
			--tool_base="$ROOT/usr/sbin" || die "cannot pack firmware"
	fi
	chmod +x ${UPDATE_SCRIPT}
}

cros-firmware_src_install() {
	# install the main updater program
	dosbin $UPDATE_SCRIPT || die "failed to install update script"

	# install factory wipe script
	dosbin firmware-factory-wipe
}

EXPORT_FUNCTIONS src_unpack src_compile src_install
