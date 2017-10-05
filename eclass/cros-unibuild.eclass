# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# Check for EAPI 4+
case "${EAPI:-0}" in
4|5|6) ;;
*) die "unsupported EAPI (${EAPI}) in eclass (${ECLASS})" ;;
esac

# @ECLASS-VARIABLE: UNIBOARD_CROS_CONFIG_DIR
# @DESCRIPTION:
#  This is the installation directory of cros-config data.
UNIBOARD_CROS_CONFIG_DIR="/usr/share/chromeos-config"

# @ECLASS-VARIABLE: UNIBOARD_DTB_INSTALL_PATH
# @DESCRIPTION:
#  This is the filename of the master configuration for use with doins.
UNIBOARD_DTB_INSTALL_PATH="${UNIBOARD_CROS_CONFIG_DIR}/config.dtb"

# @ECLASS-VARIABLE: UNIBOARD_DTS_DIR
# @DESCRIPTION:
#  This is the installation directory of the device-tree source files.
UNIBOARD_DTS_DIR="${UNIBOARD_CROS_CONFIG_DIR}/dts"

# @ECLASS-VARIABLE: UNIBOARD_CROS_CONFIG_FILES_DIR
# @DESCRIPTION:
#  This is the installation directory of files referenced in the model.dtsi.
UNIBOARD_CROS_CONFIG_FILES_DIR="/usr/share/chromeos-config/files"

# @FUNCTION: install_model_file
# @USAGE:
# @DESCRIPTION:
# Installs the .dtsi file for the current board. This is called from the
# chromeos-config-<board> public ebuild. It is named "model.dtsi".
install_model_file() {
	[[ $# -eq 0 ]] || die "${FUNCNAME}: takes no arguments"

	local dest="model.dtsi"

	einfo "Installing ${dest} to ${UNIBOARD_DTS_DIR}"

	# Avoid polluting callers with our insinto.
	(
		insinto "${UNIBOARD_DTS_DIR}"
		newins ${FILESDIR}/model.dtsi "${dest}"
	)
}

# @FUNCTION: install_private_model_file
# @USAGE:
# @DESCRIPTION:
# Installs the .dtsi file for the current board. This is intended to be called
# from the chromeos-config-<board> private ebuild. The file is named
# "private-model.dtsi".
install_private_model_file() {
	[[ $# -eq 0 ]] || die "${FUNCNAME}: takes no arguments"

	local dest="private-model.dtsi"

	einfo "Installing ${dest} to ${UNIBOARD_DTS_DIR}"

	# Avoid polluting callers with our insinto.
	(
		insinto "${UNIBOARD_DTS_DIR}"
		newins ${FILESDIR}/model.dtsi "${dest}"
	)
}

# Find .dtsi files in a given directory tree.
# Args:
#   $1: Directory to search.
# Returns:
#   Exports a 'files' variable containing the array of files found.
_find_configs() {
	local file

	while read -d $'\0' -r file; do
		files+=( "${file}" )
	done < <(find "$1" -name '*.dtsi' -print0)
}

# @FUNCTION: install_private_model_files
# @USAGE:
# @DESCRIPTION:
# Installs all .dtsi files for the current board. This is intended to be called
# from the chromeos-config-<board> private ebuild. The files are named
# "private-<fname>.dtsi".
install_private_model_files() {
	local files

	[[ $# -eq 0 ]] || die "${FUNCNAME}: takes no arguments"

	_find_configs "${FILESDIR}"

	einfo "Installing ${#files[@]} files to ${UNIBOARD_DTS_DIR}"

	# Avoid polluting callers with our newins.
	(
		insinto "${UNIBOARD_DTS_DIR}"
		for file in "${files[@]}"; do
			local dest="private-${file##*/}"

			einfo "Installing ${dest}"
			newins "${file}" "${dest}"
		done
	)
}

# Simple function to return the path to the master configuration file.
get_dtb_path() {
	local f="${SYSROOT}${UNIBOARD_DTB_INSTALL_PATH}"
	if [[ -e "${f}" ]]; then
		echo "${f}"
	else
		# just for cros-config case
		f="${D}${UNIBOARD_DTB_INSTALL_PATH}"
		if [[ -e "${f}" ]]; then
			echo "${f}"
		else
			die "${f} missing. Do you have the right DEPEND='s?"
		fi
	fi
}

# @FUNCTION: get_model_conf_value
# @USAGE: <model> <path> <prop>
# @RETURN: value of the property, or empty if not found
# @DESCRIPTION:
# Obtain a configuration value for a given model. Will only follow phandles for
# /firmware.
# @CODE
# model: name of model to lookup.
# path: path to config string, e.g. "/". Starts with "/".
# prop: name of property to read (e.g. "wallpaper").
# @CODE
get_model_conf_value() {
	[[ $# -eq 3 ]] || die "${FUNCNAME}: takes 3 arguments"

	local model="$1"
	local path="$2"
	local prop="$3"
	cros_config_host_py --model "${model}" get "${path}" "${prop}"
}

# @FUNCTION: get_model_list
# @USAGE:
# @DESCRIPTION:
# Obtain a list of all of the models known to the build root DTB
# @RETURN:
# A newline-separated string representing the list of known models; may be empty
get_model_list() {
	[[ $# -eq 0 ]] || die "${FUNCNAME}: takes no arguments"

	cros_config_host_py list-models
}

# Internal function to compile the device tree file on-the-fly and output a
# file suitable for piping into fdtget, etc.
# TODO(crbug.com/771187): Move this to cros_config.
get_dtb_data() {
	if [[ -f ${SYSROOT}${UNIBOARD_DTB_INSTALL_PATH} ]]; then
		cat ${SYSROOT}${UNIBOARD_DTB_INSTALL_PATH}
	else
		# This function is called before FILESDIR is set so figure it out from
		# the ebuild filename.
		local basedir="$(dirname "${EBUILD}")/.."
		local configdir="${basedir}/chromeos-config-bsp/files"
		local files

		# We are not allowed to access the ROOT directory here, so compile the
		# model fragment on the fly and pull out the value we want.

		# We cannot die here if there are no config files as this function is
		# called by non-unibuild boards. We just need to output an empty
		# config. But do skip this if there is no config BSP directory at all.
		if [[ -d "${configdir}" ]]; then
			_find_configs "${configdir}"
		fi
		echo "/dts-v1/; / { chromeos { family: family { }; " \
			"models: models { }; }; };" |
			cat "-" "${files[@]}" |
			dtc -O dtb
	fi
}

# @FUNCTION: get_model_list_noroot
# @USAGE:
# @DESCRIPTION:
# Obtain a list of all of the models known to the build DTB in files/
# @RETURN:
# A newline-separated string representing the list of known models; may be empty
get_model_list_noroot() {
	[[ $# -eq 0 ]] || die "${FUNCNAME}: takes no arguments"

	get_dtb_data | cros_config_host_py -c - list-models
}

# @FUNCTION: get_unique_model_conf_value_set
# @USAGE: <path> <prop>
# @RETURN:
# IFS separated string representing unique value of the property
# across all models or empty if not found.
# @DESCRIPTION:
# Obtain a set of configuration values across all models. As a set,
# contains only unique values.
# @CODE
# path: path to config string, e.g. "/". Starts with "/".
# prop: name of property to read (e.g. "wallpaper").
# @CODE
get_unique_model_conf_value_set() {
	[[ $# -eq 2 ]] || die "${FUNCNAME}: takes 2 arguments"

	local path="$1"
	local prop="$2"
	local models=( $(get_model_list) )
	local model
	local values=()

	for model in "${models[@]}"; do
		values+=(
			$(get_model_conf_value "${model}" "${path}" "${prop}" \
			2>/dev/null)
		)
	done

	printf '%s\n' "${values[@]}" | sort -u
}

# @FUNCTION: get_unique_model_conf_value_set_noroot
# @USAGE: <path> <prop>
# @RETURN:
# IFS separated string representing unique value of the property
# across all models in the files/ directory or empty if not found.
# @DESCRIPTION:
# Obtain a set of configuration values across all models. As a set,
# contains only unique values.
# @CODE
# path: path to config string, e.g. "/". Starts with "/".
# prop: name of property to read (e.g. "wallpaper").
# @CODE
get_unique_model_conf_value_set_noroot() {
	[[ $# -eq 2 ]] || die "${FUNCNAME}: takes 2 arguments"
	local path="$1"
	local prop="$2"
	local models=( $(get_model_list_noroot) )
	local model
	local values=()

	for model in "${models[@]}"; do
		values+=(
			$(get_model_conf_value_noroot "${model}" "${path}" \
			"${prop}" 2>/dev/null)
		)
	done

	printf '%s\n' "${values[@]}" | sort -u
}

# @FUNCTION: get_model_conf_value_noroot
# @USAGE: <model> <path> <prop>
# @DESCRIPTION:
# Obtain a configuration value for a given model. This works without needing
# access to the root directory, so it is suitable for getting information for
# use # in SRC_URI, for example.
# It requires a symlink in the calling ebuild from ${FILESDIR}/model.dtsi to
# the board's configuration file. It also requires a subslot dependency. Will
# only follow phandles for /firmware.
# @RETURN: value of the property, or empty if not found
# @CODE
# model: name of model to lookup.
# path: path to config string, e.g. "/". Starts with "/".
# prop: name of property to read (e.g. "wallpaper").
# @CODE
get_model_conf_value_noroot() {
	[[ $# -eq 3 ]] || die "${FUNCNAME}: takes 3 arguments"

	local model="$1"
	local path="$2"
	local prop="$3"

	get_dtb_data | cros_config_host_py -c - --model "${model}" get "${path}" \
		"${prop}"
}

# @FUNCTION: install_thermal_files
# @USAGE:
# @DESCRIPTION:
# Install files related to thermal operation. Currently this is only the DPTF
# (Dynamic Platform and Thermal Framework) datavaults, typically called dptf.dv
install_thermal_files() {
	[[ $# -eq 0 ]] || die "${FUNCNAME}: takes no arguments"

	local models=( $(get_model_list) )
	local model
	local dptf

	einfo "unibuild: Installing thermal files"
	for model in "${models[@]}"; do
		dptf="$(get_model_conf_value "${model}" "/thermal" "dptf-dv")"
		if [[ -n "${dptf}" ]]; then
			einfo "   - ${dptf}"
			insinto "$(dirname /etc/dptf/${dptf})"
			doins "${FILESDIR}/${dptf}"
		fi
	done
}

# Install touch firmware and create a symlink for 'request firmware' hotplug.
#   $1: Filename of firmware in ${FILESDIR}
#   $2: Full path to symlink in /lib/firmware
_install_fw() {
	local firmware="$1"
	local symlink="$2"

	# TODO(crbug.com/769575): Remove this hard-coded path.
	local touchfw_dir="/opt/google/touch/firmware"

	local src=''
	if [[ -e "${FILESDIR}/${firmware}" ]]; then
		src="${FILESDIR}/${firmware}"
	elif [[ -e "${SYSROOT}${UNIBOARD_CROS_CONFIG_FILES_DIR}/${firmware}" ]]; then
		src="${SYSROOT}${UNIBOARD_CROS_CONFIG_FILES_DIR}/${firmware}"
	else
		# TODO(sjg): can be enabled once reef-uni's
		# chromeos-touch-firmware-baseboard-reef is adjusted to copy files in place
		# for chromeos-config and virtual/chromeos-bsp is added to deps of it.
		# die "${firmware} is missing and cannot be installed"
		:
	fi

	if [[ -n "${src}" ]]; then
		elog "Installing ${firmware} with symlink from ${symlink}"
		local dest="${touchfw_dir}/${firmware}"

		insinto "$(dirname "${dest}")"
		doins "${src}"
		dosym "${dest}" "/lib/firmware/${symlink}"
	fi
}

# @FUNCTION: unibuild_install_touch_files
# @USAGE:
# @DESCRIPTION:
# Install files related to touch firmware. This includes firmware for the
# touchscreen, touchpad and stylus.
unibuild_install_touch_files() {
	einfo "unibuild: Installing touch files"
	while read -r fwfile; do
		read -r symlink
		_install_fw "${fwfile}" "${symlink}"
	done < <(cros_config_host_py get-touch-firmware-files)
}

# @FUNCTION: unibuild_install_audio_files
# @USAGE:
# @DESCRIPTION:
# Install files related to audio. This includes cras, alsa and hotwording
# topology firmware.
unibuild_install_audio_files() {
	[[ $# -eq 0 ]] || die "${FUNCNAME}: takes no arguments"

	local source dest
	einfo "unibuild: Installing audio files"
	while read -r source; do
		read -r dest
		einfo "   - ${source}"
		insinto "$(dirname "${dest}")"
		newins "${FILESDIR}/${source}" "$(basename "${dest}")"
	done < <(cros_config_host_py get-audio-files)
}
