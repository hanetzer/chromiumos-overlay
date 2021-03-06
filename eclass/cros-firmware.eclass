# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
#
# Original Author: The Chromium OS Authors <chromium-os-dev@chromium.org>
# Purpose: Generate shell script containing firmware update bundle.
#

# Skip unibuild if we don't have a board set.
if [[ ${#CROS_BOARDS[@]} -eq 0 ]]; then
	CROS_BOARDS=( "none" )
fi

if [[ -z "${EBUILD}" ]]; then
	die "This eclass needs EBUILD environment variable."
fi

inherit cros-workon cros-unibuild

# @ECLASS-VARIABLE: CROS_FIRMWARE_BCS_OVERLAY
# @DESCRIPTION: (Optional) Name of board overlay on Binary Component Server
: ${CROS_FIRMWARE_BCS_OVERLAY:=\
$(basename "$(dirname "$(dirname "$(dirname "${EBUILD}")")")")}

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
: ${CROS_FIRMWARE_SCRIPT:=updater4.sh}

# @ECLASS-VARIABLE: CROS_FIRMWARE_EXTRA_LIST
# @DESCRIPTION: (Optional) Semi-colon separated list of additional resources
: ${CROS_FIRMWARE_EXTRA_LIST:=}

# Check for EAPI 2+
case "${EAPI:-0}" in
2|3|4|5|6) ;;
*) die "unsupported EAPI (${EAPI}) in eclass (${ECLASS})" ;;
esac

# $board-overlay/make.conf may contain these flags to always create "firmware
# from source".
IUSE="bootimage cros_ec unibuild"

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
RDEPEND=""

# For unibuild we need EAPI 5 for the sub-slot dependency feature.
case "${EAPI:-0}" in
5|6)
	DEPEND+=" unibuild? (
			chromeos-base/chromeos-config:=
		) "
	RDEPEND+=" unibuild? (
			chromeos-base/chromeos-config:=
		) "
	;;
esac

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
RDEPEND="${RDEPEND}
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

# Output the URI associated with a file to download. This can be added to the
# SRC_URI variable.
# Portage will then take care of downloading these files before the src_unpack
# phase starts.
# Args
#   $1: Input file to read, with prefix (e.g. "bcs://Reef.9042.72.0.tbz2")
#   $2: Overlay name (e.g. "reef-private")
#   $3: Board directory containing file (e.g. "chromeos-firmware-reef")
_add_uri() {
	local input="$1"
	local overlay="$2"
	local board="$3"
	local protocol="${input%%://*}"
	local uri="${input#*://}"
	local user="bcs-${overlay#variant-*-}"
	local bcs_url="gs://chromeos-binaries/HOME/${user}/overlay-${overlay}"

	# Input without ${protocol} are local files (ex, ${FILESDIR}/file).
	case "${protocol}" in
		bcs)
			echo "${bcs_url}/${CATEGORY}/${board}/${uri}"
			;;
		http|https|gs)
			echo "${input}"
			;;
	esac
}

# Output a URL for the given firmware variable.
# This calls _add_uri() after setting up the required parameters.
#  $1: Variable containing the required filename (e.g. "FW_IMAGE_LOCATION")
_add_source() {
	local var="$1"
	local src_uri="$2"
	local overlay="${CROS_FIRMWARE_BCS_OVERLAY#overlay-}"
	local input="${!var}"

	_add_uri "${input}" "${overlay}" "${PN}"
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
	case "${EAPI:-0}" in
	1|2|3|4)
		use unibuild &&
			die "Update your EAPI version to 5 to use unibuild"
		;;
	esac

	cros-workon_src_unpack
	local i

	if ! use unibuild; then
		for i in {FW,FW_RW,EC,PD}_IMAGE_LOCATION; do
			_unpack_archive ${i}
		done

		for ((i = 0; i < ${#EXTRA_LOCATIONS[@]}; i++)); do
			_unpack_archive "EXTRA_LOCATIONS[$i]"
		done
	fi
}

# Add members to an array.
#  $1: Array variable to append to.
#  $2..: Arguments to append, each to be put in its own array element.
_append_var() {
	local var="$1"
	shift
	eval "${var}+=( \"\$@\" )"
}

# Add a string command-line flag with its value to an array.
# If the value is empty then this function does nothing.
#  $1: Array variable to append to.
#  $2: Flag (e.g. "-b").
#  $3: Value (e.g. "bios.bin").
_add_param() {
	local var="$1"
	local flag="$2"
	local value="$3"

	[[ -n "${value}" ]] && _append_var "${var}" "${flag}" "${value}"
}

# Add a boolean command-line flag to an array.
# If the value is empty then this function does nothing, otherwise it
# appends the flag.
#  $1: Array variable to append to.
#  $2: Flag (e.g. "--create_bios_rw_image").
#  $3: Value (e.g. "${IMAGE}"), only used to determine flag presence.
_add_bool_param() {
	local var="$1"
	local flag="$2"
	local value="$3"

	[[ -n "${value}" ]] && _append_var "${var}" "${flag}"
}

cros-firmware_src_compile() {
	local image_cmd=() ext_cmd=()
	local root="${ROOT%/}"
	local output_file="updater.sh"

	# Prepare extra commands
	_add_param ext_cmd --tool_base \
		"${root}/firmware/utils:${root}/usr/sbin:${root}/usr/bin"
	_add_param ext_cmd --script "${CROS_FIRMWARE_SCRIPT}"
	if use unibuild; then
		if [[ -e "${SYSROOT}/${UNIBOARD_YAML_CONFIG}" ]]; then
			image_cmd+=(
				-c "${SYSROOT}/${UNIBOARD_YAML_CONFIG}"
				-i "${DISTDIR}"
			)
		else
			image_cmd+=(
				-c "${SYSROOT}/${UNIBOARD_DTB_INSTALL_PATH}"
				-i "${DISTDIR}"
			)
		fi
		einfo "Build ${BOARD_USE} firmware updater:" \
			"${image_cmd[*]} ${ext_cmd[*]}"
		./pack_firmware.py "${image_cmd[@]}" "${ext_cmd[@]}" \
			-o "${UPDATE_SCRIPT}" ||
			die "Cannot pack firmware."

		if use bootimage; then
			if [[ -e "${SYSROOT}/${UNIBOARD_YAML_CONFIG}" ]]; then
				image_cmd+=(
					-c "${SYSROOT}/${UNIBOARD_YAML_CONFIG}"
					-i "${DISTDIR}"
				)
			else
				image_cmd+=(
					-c "${SYSROOT}/${UNIBOARD_DTB_INSTALL_PATH}"
					-i "${DISTDIR}"
				)
			fi

			einfo "Updater for local fw"
			# Tell pack_firmware.py where to find the files.
			# 'BUILD_TARGET' will be replaced with the the
			# build-targets config from the model.dtsi file.
			image_cmd+=(
				-b "${root}/firmware/image-BUILD_TARGET.bin"
				-e "${root}/firmware/BUILD_TARGET/ec.bin"
				-p "${root}/firmware/BUILD_TARGET/pd.bin"
			)
			./pack_firmware.py -l "${image_cmd[@]}" \
				"${ext_cmd[@]}" -o "${output_file}" ||
				die "Cannot pack local firmware."
		fi
	else
		# Prepare images for legacy mode (not unified builds)
		_add_param image_cmd -b "${FW_IMAGE_LOCATION}"
		_add_param image_cmd -e "${EC_IMAGE_LOCATION}"
		_add_param image_cmd -p "${PD_IMAGE_LOCATION}"
		_add_param image_cmd -w "${FW_RW_IMAGE_LOCATION}"
		_add_bool_param image_cmd --create_bios_rw_image \
			"${CROS_FIRMWARE_BUILD_MAIN_RW_IMAGE}"

		# Prepare extra commands
		_add_param ext_cmd --extra \
			"$(IFS=:; echo "${EXTRA_LOCATIONS[*]}")"
		_add_param ext_cmd --stable_main_version \
			"${CROS_FIRMWARE_STABLE_MAIN_VERSION}"
		_add_param ext_cmd --stable_ec_version \
			"${CROS_FIRMWARE_STABLE_EC_VERSION}"
		_add_param ext_cmd --stable_pd_version \
			"${CROS_FIRMWARE_STABLE_PD_VERSION}"

		# Pack firmware update script!
		if [ ${#image_cmd[@]} -ne 0 ]; then
			image_cmd+=( --legacy )
			einfo "Build ${BOARD_USE} firmware updater:" \
				"${image_cmd[*]} ${ext_cmd[*]}"
			./pack_firmware.py "${image_cmd[@]}" "${ext_cmd[@]}" \
				-o "${UPDATE_SCRIPT}" ||
				die "Cannot pack firmware."
		fi

		# Create local updaters
		if use bootimage; then
			local local_image_cmd=(-b "${root}/firmware/image.bin")
			if use cros_ec; then
				local_image_cmd+=(-e "${root}/firmware/ec.bin")
				if [ -e "$root/firmware/pd.bin" ]; then
					local_image_cmd+=(-p
						"${root}/firmware/pd.bin")
				fi
			fi

			einfo "Updater for local fw"
			./pack_firmware.py -o "${output_file}" --legacy \
				"${local_image_cmd[@]}" "${ext_cmd[@]}" ||
				die "Cannot pack local firmware."
			if [[ ${#image_cmd[@]} -eq 0 ]]; then
				# When no pre-built binaries are available,
				# dupe local updater to system updater.
				cp -f "${output_file}" "${UPDATE_SCRIPT}"
			fi
		fi
	fi

	if [ ${#image_cmd[@]} -eq 0 ]; then
		# Create an empty update script for the generic case
		# (no need to update)
		einfo "Building empty firmware update script"
		echo -n > "${UPDATE_SCRIPT}"
	fi

	if ! use bootimage && use cros_ec; then
		# TODO(hungte) Deal with a platform that has only EC and no
		# BIOS, which is usually incorrect configuration.
		# We only warn here to allow for BCS based firmware to still
		# generate a proper chromeos-firmwareupdate update script.
		ewarn "WARNING: platform has no local BIOS."
		ewarn "EC-only is not supported."
		ewarn "Not generating a locally built firmware update script."
	fi
}

cros-firmware_src_install() {
	# install updaters for firmware-from-source archive.
	if use bootimage; then
		exeinto /firmware
		doexe updater*.sh
	fi

	# skip anything else if no main updater program.
	if [[ ! -s "${UPDATE_SCRIPT}" ]]; then
		return
	fi

	# install the main updater program if available.
	dosbin "${UPDATE_SCRIPT}"

	# install additional scripts ( sbin/firmware-*.${version} ).
	local main_script="${CROS_FIRMWARE_SCRIPT##*updater}"
	local version="${main_script%.sh}"
	for script in "${S}"/sbin/firmware-* "${S}"/sbin/chromeos-*; do
		local script_base="$(basename "${script}")"
		if [[ "${script_base#*.}" == "${script_base}" ]] &&
		   [[ ! -f "${script}.${version}" ]]; then
			# A general script to be installed on all systems, if no
			# version-specific script exists.
			dosbin "${script}"
		elif [[ "${script_base##*.}" == "${version}" ]]; then
			# A script only installed if version matches.
			newsbin "${script}" "${script_base%.*}"
		fi
	done

	# install ${FILESDIR}/sbin/* (usually board-setgoodfirmware).
	if [[ -d "${FILESDIR}"/sbin ]]; then
		dosbin "${FILESDIR}"/sbin/*
	fi
}

# Trigger tests on each firmware build. While there is a chromeos-firmware-1
# ebuild which could be used to run these tests on the host, it doesn't do
# anything at present, and the usual workflow is to build firmware for a
# particular board. This way it is more likely that people will see any
# failures in their normal workflow.
cros-firmware_src_test() {
	local fname

	for fname in *test.py; do
		einfo "Running tests in ${fname}"
		python "${fname}" || die "Tests failed at ${fname}"
	done
}

# @FUNCTION: _expand_list
# @USAGE <var> <ifs> <string>
# @DESCRIPTION:
# Internal function to expand a string (separated by ifs) into bash array.
_expand_list() {
	local var="$1" ifs="$2"
	IFS="${ifs}" read -r -a ${var} <<<"${*:3}"
}

# Add any files mentioned in the master configuration to SRC_URI so that they
# will be downloaded if unibuild is enabled.
cros-firmware_setup_source_unibuild() {
	local uri_list

	uri_list=$(cros_config_host_local get-firmware-uris)
	if [[ -n "${uri_list// }" ]]; then
		SRC_URI+="unibuild? ( ${uri_list} )"
	fi
}

# @FUNCTION: cros-firmware_setup_source
# @DESCRIPTION:
# Configures all firmware binary source files to SRC_URI, and updates local
# destination mapping (*_LOCATION). Must be invoked after CROS_FIRMWARE_*_IMAGE
# are set. This also reads the master configuration if available and adds files
# from there for unified builds. The result is something like:
#
# SRC_URI="!unibuild? ( file1 file2 ) unibuild? ( file3 file3 )"
#
# With this we will end up downloading either the unibuild files or the
# !unibuild files, depending on the 'unibuild' USE flag.
cros-firmware_setup_source() {
	# This function is called before FILESDIR is set so figure it out from
	# the ebuild filename.
	local basedir="$(dirname "${EBUILD}")"
	local files="${basedir}/files"
	local i uris

	if [[ -f "${files}/srcuris" ]]; then
		mapfile -t uris -d ' ' < "${files}/srcuris"
		SRC_URI+=( "${uris[@]}" )
		return
	fi

	FW_IMAGE_LOCATION="${CROS_FIRMWARE_MAIN_IMAGE}"
	FW_RW_IMAGE_LOCATION="${CROS_FIRMWARE_MAIN_RW_IMAGE}"
	EC_IMAGE_LOCATION="${CROS_FIRMWARE_EC_IMAGE}"
	PD_IMAGE_LOCATION="${CROS_FIRMWARE_PD_IMAGE}"
	_expand_list EXTRA_LOCATIONS ";" "${CROS_FIRMWARE_EXTRA_LIST}"

	# Always add ${FILESDIR}/extra if available.
	if [[ -d "${FILESDIR}/extra" ]]; then
		EXTRA_LOCATIONS+=("${FILESDIR}/extra")
	fi

	# Add these files for use if unibuild is not set.
	for i in {FW,FW_RW,EC,PD}_IMAGE_LOCATION; do
		uris+=" $(_add_source ${i})"
	done

	for ((i = 0; i < ${#EXTRA_LOCATIONS[@]}; i++)); do
		uris+=" $(_add_source "EXTRA_LOCATIONS[$i]")"
	done
	if [[ -n "${uris// }" ]]; then
		SRC_URI+="!unibuild? ( ${uris} ) "
	fi

	# Now add files for use if USE=unibuild is enabled.
	cros-firmware_setup_source_unibuild
}

# If "inherit cros-firmware" appears at end of ebuild file, build source URI
# automatically. Otherwise, you have to put an explicit call to
# "cros-firmware_setup_source" at end of ebuild file.
[[ -n "${CROS_FIRMWARE_MAIN_IMAGE}" ]] && cros-firmware_setup_source

EXPORT_FUNCTIONS src_unpack src_compile src_install src_test
