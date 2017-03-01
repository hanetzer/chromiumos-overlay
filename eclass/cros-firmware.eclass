# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
#
# Original Author: The Chromium OS Authors <chromium-os-dev@chromium.org>
# Purpose: Generate shell script containing firmware update bundle.
#

inherit cros-workon

# @ECLASS-VARIABLE: CROS_FIRMWARE_BCS_OVERLAY
# @DESCRIPTION: (Optional) Name of board overlay on Binary Component Server
: ${CROS_FIRMWARE_BCS_OVERLAY:=${BOARD_OVERLAY##*/}}

# @ECLASS-VARIABLE: CROS_FIRMWARE_MAIN_IMAGE
# @DESCRIPTION: (Optional) Location of system firmware (BIOS) image
: ${CROS_FIRMWARE_MAIN_IMAGE:=}

# @ECLASS-VARIABLE: CROS_FIRMWARE_MAIN_RW_IMAGE
# @DESCRIPTION: (Optional) Location of RW system firmware image
: ${CROS_FIRMWARE_MAIN_RW_IMAGE:=}

# @ECLASS-VARIABLE: CROS_FIRMWARE_STABLE_MAIN_VERSION
# @DESCRIPTION: (Optional) Version name of stabled system firmware
: ${CROS_FIRMWARE_STABLE_MAIN_VERSION:=}

# @ECLASS-VARIABLE: CROS_FIRMWARE_BUILD_MAIN_RW_IMAGE
# @DESCRIPTION: (Optional) Re-sign and generate a RW system firmware image.
: ${CROS_FIRMWARE_BUILD_MAIN_RW_IMAGE:=}

# @ECLASS-VARIABLE: CROS_FIRMWARE_EC_IMAGE
# @DESCRIPTION: (Optional) Location of EC firmware image
: ${CROS_FIRMWARE_EC_IMAGE:=}

# @ECLASS-VARIABLE: CROS_FIRMWARE_EC_VERSION
# @DESCRIPTION: (Optional) Version name of EC firmware
: ${CROS_FIRMWARE_EC_VERSION:=}

# @ECLASS-VARIABLE: CROS_FIRMWARE_STABLE_EC_VERSION
# @DESCRIPTION: (Optional) Version name of stabled EC firmware
: ${CROS_FIRMWARE_STABLE_EC_VERSION:=}

# @ECLASS-VARIABLE: CROS_FIRMWARE_PD_IMAGE
# @DESCRIPTION: (Optional) Location of PD firmware image
: ${CROS_FIRMWARE_PD_IMAGE:=}

# @ECLASS-VARIABLE: CROS_FIRMWARE_STABLE_PD_VERSION
# @DESCRIPTION: (Optional) Version name of stabled PD firmware
: ${CROS_FIRMWARE_STABLE_PD_VERSION:=}

# @ECLASS-VARIABLE: CROS_FIRMWARE_SCRIPT
# @DESCRIPTION: (Optional) Entry script file name of updater
: ${CROS_FIRMWARE_SCRIPT:=}

# @ECLASS-VARIABLE: CROS_FIRMWARE_BINARY
# @DESCRIPTION: (Optional) location of custom flashrom tool
: ${CROS_FIRMWARE_FLASHROM_BINARY:=}

# @ECLASS-VARIABLE: CROS_FIRMWARE_EXTRA_LIST
# @DESCRIPTION: (Optional) Semi-colon separated list of additional resources
: ${CROS_FIRMWARE_EXTRA_LIST:=}

# @ECLASS-VARIABLE: CROS_FIRMWARE_FORCE_UPDATE
# @DESCRIPTION: (Optional) Always add "force update firmware" tag.
: ${CROS_FIRMWARE_FORCE_UPDATE:=}

# Check for EAPI 2+
case "${EAPI:-0}" in
2|3|4|5|6) ;;
*) die "unsupported EAPI (${EAPI}) in eclass (${ECLASS})" ;;
esac

# $board-overlay/make.conf may contain these flags to always create "firmware
# from source".
IUSE="bootimage cros_ec"

# Some tools (flashrom, iotools, mosys, ...) were bundled in the updater so we
# don't write RDEPEND=$DEPEND. RDEPEND should have an explicit list of what it
# needs to extract and execute the updater.
DEPEND="
	>=chromeos-base/vboot_reference-1.0-r230
	chromeos-base/vpd
	dev-util/shflags
	>=sys-apps/flashrom-0.9.4-r269
	sys-apps/mosys
	"

# Build firmware from source.
DEPEND="$DEPEND
	bootimage? ( sys-boot/chromeos-bootimage )
	cros_ec? ( chromeos-base/chromeos-ec )
	"

# Maintenance note:  The factory install shim downloads and executes
# the firmware updater.  Consequently, runtime dependencies for the
# updater are also runtime dependencies for the install shim.
#
# The contents of RDEPEND below must also be present in the
# chromeos-base/factory_installer ebuild in PROVIDED_DEPEND.
# If you make any change to the list below, you may need to make a
# matching change in the factory_installer ebuild.
#
# TODO(hungte) remove gzip/tar if we have busybox
RDEPEND="
	app-arch/gzip
	app-arch/sharutils
	app-arch/tar
	chromeos-base/vboot_reference
	sys-apps/util-linux"

RESTRICT="mirror"

# Local variables.

UPDATE_SCRIPT="chromeos-firmwareupdate"
FW_IMAGE_LOCATION=""
FW_RW_IMAGE_LOCATION=""
EC_IMAGE_LOCATION=""
PD_IMAGE_LOCATION=""
EXTRA_LOCATIONS=()

# New SRC_URI based approach.

_add_source() {
	local var="$1"
	local input="${!var}"
	local protocol="${input%%://*}"
	local uri="${input#*://}"
	local overlay="${CROS_FIRMWARE_BCS_OVERLAY#overlay-}"
	local user="bcs-${overlay#variant-*-}"
	local bcs_url="gs://chromeos-binaries/HOME/${user}/overlay-${overlay}"

	# Input without ${protocol} are local files (ex, ${FILESDIR}/file).
	case "${protocol}" in
		bcs)
			SRC_URI+=" ${bcs_url}/${CATEGORY}/${PN}/${uri}"
			;;
		http|https|gs)
			SRC_URI+=" ${input}"
			;;
	esac
}

_unpack_archive() {
	local var="$1"
	local input="${!var}"
	local archive="${input##*/}"
	local folder="${S}/.dist/${archive}"

	# Remote source files (bcs://, http://, ...) are downloaded into
	# ${DISTDIR}, which is the default location for command 'unpack'.
	# For any other files (ex, ${FILESDIR}/file), use complete file path.
	local unpack_name="${input}"
	if [[ "${unpack_name}" =~ "://" ]]; then
		input="${DISTDIR}/${archive}"
		unpack_name="${archive}"
	fi

	case "${input##*.}" in
		tar|tbz2|tbz|bz|gz|tgz|zip|xz) ;;
		*)
			eval ${var}="'${input}'"
			return
			;;
	esac

	mkdir -p "${folder}" || die "Not able to create ${folder}"
	(cd "${folder}" && unpack "${unpack_name}") ||
		die "Failed to unpack ${unpack_name}."
	local contents=($(ls "${folder}"))
	if [[ ${#contents[@]} -gt 1 ]]; then
		# Currently we can only serve one file (or directory).
		ewarn "WARNING: package ${input} contains multiple files."
	fi
	eval ${var}="'${folder}/${contents}'"
}

cros-firmware_src_unpack() {
	cros-workon_src_unpack
	local i

	for i in {FW,FW_RW,EC,PD}_IMAGE_LOCATION; do
		_unpack_archive ${i}
	done

	for ((i = 0; i < ${#EXTRA_LOCATIONS[@]}; i++)); do
		_unpack_archive "EXTRA_LOCATIONS[$i]"
	done
}

_old_add_param() {
	local prefix="$1"
	local value="$2"

	if [[ -n "$value" ]]; then
		echo "$prefix '$value' "
	fi
}

_old_add_bool_param() {
	local prefix="$1"
	local value="$2"

	if [[ -n "$value" ]]; then
		echo "$prefix "
	fi
}

cros-firmware_src_compile() {
	local old_image_cmd="" old_ext_cmd="" local_old_image_cmd=""
	local root="${ROOT%/}"

	# Prepare images
	old_image_cmd+="$(_old_add_param -b "${FW_IMAGE_LOCATION}")"
	old_image_cmd+="$(_old_add_param -e "${EC_IMAGE_LOCATION}")"
	old_image_cmd+="$(_old_add_param -p "${PD_IMAGE_LOCATION}")"
	old_image_cmd+="$(_old_add_param -w "${FW_RW_IMAGE_LOCATION}")"
	old_image_cmd+="$(_old_add_param --ec_version "${CROS_FIRMWARE_EC_VERSION}")"
	old_image_cmd+="$(_old_add_bool_param --create_bios_rw_image \
		      "${CROS_FIRMWARE_BUILD_MAIN_RW_IMAGE}")"

	# Prepare extra commands
	old_ext_cmd+="$(_old_add_param --extra "$(IFS=:; echo "${EXTRA_LOCATIONS[*]}")")"
	old_ext_cmd+="$(_old_add_param --script "${CROS_FIRMWARE_SCRIPT}")"
	old_ext_cmd+="$(_old_add_param --flashrom "${CROS_FIRMWARE_FLASHROM_BINARY}")"
	old_ext_cmd+="$(_old_add_param --tool_base \
	            "$root/firmware/utils:$root/usr/sbin:$root/usr/bin")"
	old_ext_cmd+="$(_old_add_param --stable_main_version \
			"${CROS_FIRMWARE_STABLE_MAIN_VERSION}")"
	old_ext_cmd+="$(_old_add_param --stable_ec_version \
			"${CROS_FIRMWARE_STABLE_EC_VERSION}")"
	old_ext_cmd+="$(_old_add_param --stable_pd_version \
			"${CROS_FIRMWARE_STABLE_PD_VERSION}")"

	# Pack firmware update script!
	if [ -z "$old_image_cmd" ]; then
		# Create an empty update script for the generic case
		# (no need to update)
		einfo "Building empty firmware update script"
		echo -n > ${UPDATE_SCRIPT}
	else
		# create a new script
		einfo "Build ${BOARD_USE} firmware updater: $old_image_cmd $old_ext_cmd"
		./pack_firmware.sh $old_image_cmd $old_ext_cmd -o $UPDATE_SCRIPT ||
		die "Cannot pack firmware."
	fi

	# Create local updaters
	local local_old_image_cmd="" output_bom output_file
	if use cros_ec; then
		local_old_image_cmd+="-e $root/firmware/ec.bin "
		if [ -e "$root/firmware/pd.bin" ]; then
			local_old_image_cmd+="-p $root/firmware/pd.bin "
		fi
	fi
	if use bootimage; then
		einfo "Updater for local fw"
		output_file="updater.sh"
		./pack_firmware.sh -b $root/firmware/image.bin \
			-o $output_file $local_old_image_cmd $old_ext_cmd ||
			die "Cannot pack local firmware."
		if [[ -z "$old_image_cmd" ]]; then
			# When no pre-built binaries are available,
			# dupe local updater to system updater.
			cp -f "$output_file" "$UPDATE_SCRIPT"
		fi
	elif use cros_ec; then
		# TODO(hungte) Deal with a platform that has only EC and no
		# BIOS, which is usually incorrect configuration.
		# We only warn here to allow for BCS based firmware to still generate
		# a proper chromeos-firmwareupdate update script.
		ewarn "WARNING: platform has no local BIOS, EC only is not supported."
		ewarn "Not generating a locally built firmware update script."
	fi
}

cros-firmware_src_install() {
	# install the main updater program
	dosbin $UPDATE_SCRIPT || die "Failed to install update script."

	# install additional scripts ( sbin/firmware-*.${version} ).
	local main_script="${CROS_FIRMWARE_SCRIPT##*updater}"
	local version="${main_script%.sh}"
	for script in "${S}"/sbin/firmware-*; do
		local script_base="$(basename "${script}")"
		if [[ "${script#*.}" == "${script}" ]] &&
		   [[ ! -f "${script}.${version}" ]]; then
			# A general script to be installed on all systems, if no
			# version-specific script exists.
			dosbin "${script}"
		elif [[ "${script#*.}" == "${version}" ]]; then
			# A script only installed if version matches.
			newsbin "${script}" "${script_base%.*}"
		fi
	done

	# install updaters for firmware-from-source archive.
	if use bootimage; then
		exeinto /firmware
		doexe updater*.sh
	fi

	# The "force_update_firmware" tag file is used by chromeos-installer.
	if [ -n "$CROS_FIRMWARE_FORCE_UPDATE" ]; then
		insinto /root
		touch .force_update_firmware
		doins .force_update_firmware
	fi
}

# @FUNCTION: _expand_list
# @USAGE <var> <ifs> <string>
# @DESCRIPTION:
# Internal function to expand a string (separated by ifs) into bash array.
_expand_list() {
	local var="$1" ifs="$2"
	IFS="${ifs}" read -r -a ${var} <<<"${*:3}"
}

# @FUNCTION: cros-firmware_setup_source
# @DESCRIPTION:
# Configures all firmware binary source files to SRC_URI, and updates local
# destination mapping (*_LOCATION). Must be invoked after CROS_FIRMWARE_*_IMAGE
# are set.
cros-firmware_setup_source() {
	local i

	FW_IMAGE_LOCATION="${CROS_FIRMWARE_MAIN_IMAGE}"
	FW_RW_IMAGE_LOCATION="${CROS_FIRMWARE_MAIN_RW_IMAGE}"
	EC_IMAGE_LOCATION="${CROS_FIRMWARE_EC_IMAGE}"
	PD_IMAGE_LOCATION="${CROS_FIRMWARE_PD_IMAGE}"
	_expand_list EXTRA_LOCATIONS ";" "${CROS_FIRMWARE_EXTRA_LIST}"

	for i in {FW,FW_RW,EC,PD}_IMAGE_LOCATION; do
		_add_source ${i}
	done

	for ((i = 0; i < ${#EXTRA_LOCATIONS[@]}; i++)); do
		_add_source "EXTRA_LOCATIONS[$i]"
	done
}

# If "inherit cros-firmware" appears at end of ebuild file, build source URI
# automatically. Otherwise, you have to put an explicit call to
# "cros-firmware_setup_source" at end of ebuild file.
[[ -n "${CROS_FIRMWARE_MAIN_IMAGE}" ]] && cros-firmware_setup_source

EXPORT_FUNCTIONS src_unpack src_compile src_install
