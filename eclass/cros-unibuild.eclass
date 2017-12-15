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

# @ECLASS-VARIABLE: UNIBOARD_YAML_DIR
# @DESCRIPTION:
#  This is the installation directory of the yaml source files.
UNIBOARD_YAML_DIR="${UNIBOARD_CROS_CONFIG_DIR}/yaml"

# @ECLASS-VARIABLE: UNIBOARD_CROS_CONFIG_FILES_DIR
# @DESCRIPTION:
#  This is the installation directory of files referenced in the model.dtsi.
UNIBOARD_CROS_CONFIG_FILES_DIR="/usr/share/chromeos-config/files"

# @FUNCTION: install_private_model_file
# @USAGE:
# @DESCRIPTION:
# Installs the .dtsi/.yaml file for the current board. This is intended to be
# called from the chromeos-config-<board> private ebuild. The file is named
# "private-model.dtsi/.yaml".
install_private_model_file() {
	[[ $# -eq 0 ]] || die "${FUNCNAME}: takes no arguments"

	local dest="private-model.dtsi"

	einfo "Installing ${dest} to ${UNIBOARD_DTS_DIR}"

	# Avoid polluting callers with our insinto.
	(
		insinto "${UNIBOARD_DTS_DIR}"
		newins ${FILESDIR}/model.dtsi "${dest}"
	)

	if [[ -e "${FILESDIR}/model.yaml" ]]; then
		local dest="private-model.yaml"

		einfo "Installing ${dest} to ${UNIBOARD_YAML_DIR}"

		(
			insinto "${UNIBOARD_YAML_DIR}"
			newins ${FILESDIR}/model.yaml "${dest}"
		)
	fi
}

# @FUNCTION: _unibuild_find_configs
# @USAGE: [directory] [extension]
# @INTERNAL
# @DESCRIPTION:
# Find .dtsi/.yaml files in a given directory tree.
# Args:
#   $1: Directory to search.
#   $2: Extension to search for (.dtsi or .yaml)
# Returns:
#   Exports a 'files' variable containing the array of files found.
_unibuild_find_configs() {
	local file

	while read -d $'\0' -r file; do
		files+=( "${file}" )
	done < <(find "$1" -name "*$2" -print0)
}

# @FUNCTION: _install_model_files
# @USAGE: [prefix]
# @INTERNAL
# @DESCRIPTION:
# Find .dtsi/.yaml files in a given directory tree.
# Install model files with a given prefix:
# Args:
#   $1: Prefix to use (either "" or "private-")
_install_model_files() {
	[[ $# -eq 1 ]] || die "${FUNCNAME}: takes one arguments"

	local prefix="$1"
	local files

	_unibuild_find_configs "${FILESDIR}" ".dtsi"

	einfo "Validating ${#files[@]} files:"
	validate_config -p "${files[@]}" || die "Validation failed"

	einfo "Installing ${#files[@]} files to ${UNIBOARD_DTS_DIR}"

	# Avoid polluting callers with our newins.
	(
		insinto "${UNIBOARD_DTS_DIR}"
		for file in "${files[@]}"; do
			local dest="${file%/*}"
			dest="${prefix}${dest##*/}.dtsi"

			einfo "Installing ${dest}"
			newins "${file}" "${dest}"
		done
	)

	files=()
	_unibuild_find_configs "${FILESDIR}" ".yaml"

	if [ -n "$files" ]; then
		einfo "Installing ${#files[@]} files to ${UNIBOARD_YAML_DIR}"

		# Avoid polluting callers with our newins.
		(
			insinto "${UNIBOARD_YAML_DIR}"
			for file in "${files[@]}"; do
				local dest="${file%/*}"
				dest="${prefix}${dest##*/}.yaml"

				einfo "Installing ${dest}"
				newins "${file}" "${dest}"
			done
		)
	fi
}

# @FUNCTION: install_private_model_files
# @USAGE:
# @DESCRIPTION:
# Installs all .dtsi files for the current board. This is intended to be called
# from the chromeos-config-<board> private ebuild. The files are named
# "private-<fname>.dtsi".
install_private_model_files() {
	[[ $# -eq 0 ]] || die "${FUNCNAME}: takes no arguments"

	_install_model_files "private-"
}

# @FUNCTION: install_model_files
# @USAGE:
# @DESCRIPTION:
# Installs all .dtsi files for the current board. This is intended to be called
# from the chromeos-config-<board> public ebuild. The files are named
# "<fname>.dtsi".
install_model_files() {
	[[ $# -eq 0 ]] || die "${FUNCNAME}: takes no arguments"

	_install_model_files ""
}

# @FUNCTION: unibuild_get_dtb_data
# @USAGE:
# @DESCRIPTION:
# Internal function to compile the device tree file on-the-fly and output a
# file suitable for piping into "cros_config -c -".
# TODO(crbug.com/771187): Move this to cros_config.
unibuild_get_dtb_data() {
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
		_unibuild_find_configs "${configdir}" ".dtsi"
	fi

	echo "/dts-v1/; / { chromeos { family: family { }; " \
		"models: models { }; }; };" |
		cat "-" "${files[@]}" |
		dtc -O dtb
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

# @FUNCTION: _unibuild_install_fw
# @USAGE: [filename] [symlink path]
# @INTERNAL
# @DESCRIPTION:
# Install touch firmware and create a symlink for 'request firmware' hotplug.
#   $1: Filename of firmware in ${FILESDIR}
#   $2: Full path to symlink in /lib/firmware
_unibuild_install_fw() {
	local firmware="$1"
	local symlink="$2"

	# TODO(crbug.com/769575): Remove this hard-coded path.
	local touchfw_dir="/opt/google/touch/firmware"

	elog "Installing ${firmware} with symlink from ${symlink}"
	local dest="${touchfw_dir}/${firmware}"
	insinto "$(dirname "${dest}")"
	doins "${FILESDIR}/${firmware}"
	dosym "${dest}" "/lib/firmware/${symlink}"
}

# @FUNCTION: unibuild_install_touch_files
# @USAGE:
# @DESCRIPTION:
# Install files related to touch firmware. This includes firmware for the
# touchscreen, touchpad and stylus.
unibuild_install_touch_files() {
	einfo "unibuild: Installing touch files"
	set -o pipefail
	cros_config_host_py get-touch-firmware-files |
	( while read -r fwfile; do
		read -r symlink
		_unibuild_install_fw "${fwfile}" "${symlink}"
	done ) || die "Failed to read config"
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
	set -o pipefail
	cros_config_host_py get-audio-files |
	( while read -r source; do
		read -r dest
		einfo "   - ${source}"
		insinto "$(dirname "${dest}")"
		newins "${FILESDIR}/${source}" "$(basename "${dest}")"
	done ) || die "Failed to read config"
}
