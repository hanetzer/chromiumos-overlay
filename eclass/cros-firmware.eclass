# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
#
# Original Author: The Chromium OS Authors <chromium-os-dev@chromium.org>
# Purpose: Generate shell script containing firmware update bundle.
#

inherit cros-workon cros-binary

# @ECLASS-VARIABLE: CROS_FIRMWARE_BCS_USER_NAME
# @DESCRIPTION: (Optional) Name of user on BCS server
: ${CROS_FIRMWARE_BCS_USER_NAME:=}

# @ECLASS-VARIABLE: CROS_FIRMWARE_MAIN_IMAGE
# @DESCRIPTION: (Optional) Location of system bios image
: ${CROS_FIRMWARE_MAIN_IMAGE:=}

# @ECLASS-VARIABLE: CROS_FIRMWARE_EC_IMAGE
# @DESCRIPTION: (Optional) Location of EC firmware image
: ${CROS_FIRMWARE_EC_IMAGE:=}

# @ECLASS-VARIABLE: CROS_FIRMWARE_EC_VERSION
# @DESCRIPTION: (Optional) Version name of EC firmware
: ${CROS_FIRMWARE_EC_VERSION:="IGNORE"}

# @ECLASS-VARIABLE: CROS_FIRMWARE_PLATFORM
# @DESCRIPTION: (Optional) Platform name of firmware
: ${CROS_FIRMWARE_PLATFORM:=}

# @ECLASS-VARIABLE: CROS_FIRMWARE_SCRIPT
# @DESCRIPTION: (Optional) Entry script file name of updater
: ${CROS_FIRMWARE_SCRIPT:=}

# @ECLASS-VARIABLE: CROS_FIRMWARE_UNSTABLE
# @DESCRIPTION: (Optional) Mark firmrware as unstable (always RO+RW update)
: ${CROS_FIRMWARE_UNSTABLE:=}

# @ECLASS-VARIABLE: CROS_FIRMWARE_BINARY
# @DESCRIPTION: (Optional) location of custom flashrom tool
: ${CROS_FIRMWARE_FLASHROM_BINARY:=}

# @ECLASS-VARIABLE: CROS_FIRMWARE_EXTRA_LIST
# @DESCRIPTION: (Optional) Semi-colon separated list of additional resources
: ${CROS_FIRMWARE_EXTRA_LIST:=}

# Some tools (flashrom, iotools, mosys, ...) were bundled in the updater so we
# don't write RDEPEND=$DEPEND. RDEPEND should have an explicit list of what it
# needs to extract and execute the updater.
DEPEND="
	>=chromeos-base/vboot_reference-1.0-r230
	dev-libs/shflags
	dev-util/shflags
	>=sys-apps/flashrom-0.9.3-r36
	sys-apps/mosys
	"

# Maintenance note:  The factory install shim downloads and executes
# the firmware updater.  Consequently, runtime dependencies for the
# updater are also runtime dependencies for the install shim.
#
# The contents of RDEPEND below must also be present in the
# chromeos-base/chromeos-factoryinstall ebuild in PROVIDED_DEPEND.
# If you make any change to the list below, you may need to make a
# matching change in the factory install ebuild.
#
# TODO(hungte) remove gzip/tar if we have busybox
RDEPEND="
	app-arch/gzip
	app-arch/sharutils
	app-arch/tar
	chromeos-base/vboot_reference
	sys-apps/mosys
	sys-apps/util-linux"

# Check for EAPI 2 or 3
case "${EAPI:-0}" in
	3|2) ;;
	1|0|:) DEPEND="EAPI-UNSUPPORTED" ;;
esac

UPDATE_SCRIPT="chromeos-firmwareupdate"
FW_IMAGE_LOCATION=""
EC_IMAGE_LOCATION=""
EXTRA_LOCATIONS=""

# Returns true (0) if parameter starts with "bcs://"
_is_on_bcs() {
	[[ "${1%%://*}" = "bcs" ]]
}

# Returns true (0) if parameter starts with "file://"
_is_in_files() {
	[[ "${1%%://*}" = "file" ]]
}

# Fetch a file from the Binary Component Server
# Parameters: URI of file "bcs://filename.tbz2"
# Returns: Nothing
_bcs_fetch() {
	local filename="${1##*://}"

	URI_BASE="ssh://${CROS_FIRMWARE_BCS_USER_NAME}@git.chromium.org:6222"\
"/home/${CROS_FIRMWARE_BCS_USER_NAME}/${CATEGORY}/${PN}"
	CROS_BINARY_URI="${URI_BASE}/${filename}"
	cros-binary_fetch
}

# Unpack a tbz2 firmware archive to ${S}
# Parameters: Location of archived firmware
# Returns: Location of unpacked firmware as $RETURN_VALUE
_src_unpack() {
	local filepath="${1}"
	local filename="$(basename ${filepath})"
	mkdir -p "${S}" || die "Not able to create ${S}"
	cp "${filepath}" "${S}" || die "Can't copy ${filepath} to ${S}"
	cd "${S}" || die "Can't change directory to ${S}"
	tar -axpf "${filename}" ||
	  die "Failed to unpack ${filename}"
	RETURN_VALUE="${S}/$(tar tf ${filename})"
}

# Unpack a tbz2 archive fetched from the BCS to ${S}
# Parameters: URI of file. Example: "bcs://filename.tbz2"
# Returns: Location of unpacked firmware as $RETURN_VALUE
_bcs_src_unpack() {
	local filename="${1##*://}"
	_src_unpack "${CROS_BINARY_STORE_DIR}/${filename}"
	RETURN_VALUE="${RETURN_VALUE}"
}

# Provides the location of a firmware image given a URI.
# Unpacks the firmware image if necessary.
# Parameters: URI of file.
#   Example: "file://filename.ext" or an absolute filepath.
# Returns the absolute filepath of the unpacked firmware as $RETURN_VALUE
_firmware_image_location() {
	local source_uri=$1
	if _is_in_files "${source_uri}"; then
		local image_location="${FILESDIR}/${source_uri#*://}"
	else
		local image_location="${source_uri}"
	fi
	[[ -f "${image_location}"  ]] || die "File not found: ${image_location}"
	case "${image_location}" in
		*.tbz2 | *.tbz | *.tar.bz2 | *.tgz | *.tar.gz )
			_src_unpack "${image_location}"
			RETURN_VALUE="${RETURN_VALUE}"
			;;
		* )
			RETURN_VALUE="${image_location}"
	esac
}

cros-firmware_src_unpack() {
	cros-workon_src_unpack

	# Backwards compatibility with the older naming convention.
	if [[ -n "${CROS_FIRMWARE_BIOS_ARCHIVE}" ]]; then
		CROS_FIRMWARE_MAIN_IMAGE="bcs://${CROS_FIRMWARE_BIOS_ARCHIVE}"
	fi
	if [[ -n "${CROS_FIRMWARE_EC_ARCHIVE}" ]]; then
		CROS_FIRMWARE_EC_IMAGE="bcs://${CROS_FIRMWARE_EC_ARCHIVE}"
	fi

	# Fetch and unpack the system firmware image
	if [[ -n "${CROS_FIRMWARE_MAIN_IMAGE}" ]]; then
		if _is_on_bcs "${CROS_FIRMWARE_MAIN_IMAGE}"; then
			_bcs_fetch "${CROS_FIRMWARE_MAIN_IMAGE}"
			_bcs_src_unpack "${CROS_FIRMWARE_MAIN_IMAGE}"
			FW_IMAGE_LOCATION="${RETURN_VALUE}"
		else
			_firmware_image_location "${CROS_FIRMWARE_MAIN_IMAGE}"
			FW_IMAGE_LOCATION="${RETURN_VALUE}"
		fi
	fi

	# Fetch and unpack the EC image
	if [[ -n "${CROS_FIRMWARE_EC_IMAGE}" ]]; then
		if _is_on_bcs "${CROS_FIRMWARE_EC_IMAGE}"; then
			_bcs_fetch "${CROS_FIRMWARE_EC_IMAGE}"
			_bcs_src_unpack "${CROS_FIRMWARE_EC_IMAGE}"
			EC_IMAGE_LOCATION="${RETURN_VALUE}"
		else
			_firmware_image_location "${CROS_FIRMWARE_EC_IMAGE}"
			EC_IMAGE_LOCATION="${RETURN_VALUE}"
		fi
	fi

	# Fetch and unpack BCS resources in CROS_FIRMWARE_EXTRA_LIST
	local extra extra_list
	# For backward compatibility, ':' is still supported if there's no
	# special URL (bcs://, file://).
	local tr_source=';:' tr_target='\n\n'
	if echo "${CROS_FIRMWARE_EXTRA_LIST}" | grep -q '://'; then
		tr_source=';'
		tr_target='\n'
	fi
	extra_list="$(echo "${CROS_FIRMWARE_EXTRA_LIST}" |
			tr "$tr_source" "$tr_target")"
	for extra in $extra_list; do
		if _is_on_bcs "${extra}"; then
			_bcs_fetch "${extra}"
			_bcs_src_unpack "${extra}"
			RETURN_VALUE="${RETURN_VALUE}"
		else
			RETURN_VALUE="${extra}"
		fi
		EXTRA_LOCATIONS="${EXTRA_LOCATIONS}:${RETURN_VALUE}"
	done
	EXTRA_LOCATIONS="${EXTRA_LOCATIONS#:}"
}

cros-firmware_src_compile() {
	local image_cmd="" ext_cmd=""

	# Prepare images
	if [ -n "${FW_IMAGE_LOCATION}" ]; then
		image_cmd="$image_cmd -b ${FW_IMAGE_LOCATION}"
	fi
	if [ -n "${EC_IMAGE_LOCATION}" ]; then
		image_cmd="$image_cmd -e ${EC_IMAGE_LOCATION}"
	fi

	# Prepare extra commands
	if [ -n "$CROS_FIRMWARE_UNSTABLE" ]; then
		ext_cmd="$ext_cmd --unstable"
	fi
	if [ -n "$CROS_FIRMWARE_SCRIPT" ]; then
		ext_cmd="$ext_cmd --script $CROS_FIRMWARE_SCRIPT"
	fi
	if [ -n "$CROS_FIRMWARE_FLASHROM_BINARY" ]; then
		ext_cmd="$ext_cmd --flashrom $CROS_FIRMWARE_FLASHROM_BINARY"
	fi
	if [ -n "$EXTRA_LOCATIONS" ]; then
		ext_cmd="$ext_cmd --extra $EXTRA_LOCATIONS"
	fi

	# Pack firmware update script!
	if [ -z "$image_cmd" ]; then
		# Create an empty update script for the generic case
		# (no need to update)
		einfo "Building empty firmware update script"
		echo -n > ${UPDATE_SCRIPT}
	else
		# create a new script
		einfo "Building ${BOARD} firmware updater: $image_cmd $ext_cmd"
		"${WORKDIR}/${CROS_WORKON_LOCALNAME}"/pack_firmware.sh \
			--ec_version "${CROS_FIRMWARE_EC_VERSION}" \
                        --platform "${CROS_FIRMWARE_PLATFORM}" \
			-o ${UPDATE_SCRIPT} $image_cmd $ext_cmd \
			--tool_base="$ROOT/usr/sbin:$ROOT/usr/bin" ||
		die "Cannot pack firmware."
	fi
	chmod +x ${UPDATE_SCRIPT}
}

cros-firmware_src_install() {
	# install the main updater program
	dosbin $UPDATE_SCRIPT || die "Failed to install update script."

	# install factory wipe script
	dosbin firmware-factory-wipe
}

EXPORT_FUNCTIONS src_unpack src_compile src_install
