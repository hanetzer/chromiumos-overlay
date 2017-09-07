# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# Check for EAPI 4+
case "${EAPI:-0}" in
4|5|6) ;;
*) die "unsupported EAPI (${EAPI}) in eclass (${ECLASS})" ;;
esac

# @ECLASS-VARIABLE: UNIBOARD_DTB_INSTALL_PATH
# @DESCRIPTION:
#  This is the filename of the master configuration for use with doins.
UNIBOARD_DTB_INSTALL_PATH="/usr/share/chromeos-config/config.dtb"

# @ECLASS-VARIABLE: UNIBOARD_DTS_DIR
# @DESCRIPTION:
#  This is the installation directory of the device-tree source files.
UNIBOARD_DTS_DIR="/usr/share/chromeos-config/dts"

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

# @FUNCTION: get_model_conf_value
# @USAGE: <model> <path> <prop>
# @RETURN: value of the property, or empty if not found, in which
# case the return code indicates failure.
# @DESCRIPTION:
# Obtain a configuration value for a given model.
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
	local r
	r=$(fdtget "${SYSROOT}${UNIBOARD_DTB_INSTALL_PATH}" \
		"/chromeos/models/${model}${path}" "${prop}" 2>/dev/null)
	local ret=$?

	if [[ ${ret} -ne 0 && "${path}" =~ ^/firmware ]]; then
		# The value is missing; is it available at a firmware shares
		# phandle?
		local share
		share=$(fdtget "${SYSROOT}${UNIBOARD_DTB_INSTALL_PATH}" -f \
			"/chromeos/models/${model}/firmware" shares 2>/dev/null)

		if [[ $? -eq 0 ]]; then
			fdtget "${SYSROOT}${UNIBOARD_DTB_INSTALL_PATH}" \
			"${share}${path#/firmware}" "${prop}" 2>/dev/null
			return $?
		fi
	fi

	echo "${r}"
	return ${ret}
}

# @FUNCTION: get_model_list
# @USAGE:
# @DESCRIPTION:
# Obtain a list of all of the models known to the build root DTB
# @RETURN:
# A newline-separated string representing the list of known models; may be empty
get_model_list() {
	[[ $# -eq 0 ]] || die "${FUNCNAME}: takes no arguments"

	fdtget "${SYSROOT}${UNIBOARD_DTB_INSTALL_PATH}" \
		-l /chromeos/models 2>/dev/null
}

# Internal function to compile the device tree file on-the-fly and output a
# file suitable for piping into fdtget, etc.
# TODO(crbug.com/761264): Move this to cros_config.
get_dtb() {
	# This function is called before FILESDIR is set so figure it out from
	# the ebuild filename.
	local filesdir="$(dirname "${EBUILD}")/files"

	# We are not allowed to access the ROOT directory here, so compile the
	# model fragment on the fly and pull out the value we want.
	echo "/dts-v1/; / { chromeos { family: family { }; " \
		"models: models { }; }; };" |
		cat - "${filesdir}/model.dtsi" |
		dtc -O dtb
}

# @FUNCTION: get_model_list_noroot
# @USAGE:
# @DESCRIPTION:
# Obtain a list of all of the models known to the build DTB in files/
# @RETURN:
# A newline-separated string representing the list of known models; may be empty
get_model_list_noroot() {
	[[ $# -eq 0 ]] || die "${FUNCNAME}: takes no arguments"

	get_dtb | fdtget - -l "/chromeos/models" 2>/dev/null
}

# @FUNCTION: get_each_model_conf_value_set
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
get_each_model_conf_value_set() {
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

# @FUNCTION: get_each_model_conf_value_set_noroot
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
get_each_model_conf_value_set_noroot() {
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
# the board's configuration file. It also requires a subslot dependency.
# @RETURN: value of the property, or empty if not found, in which
# case the return code indicates failure.
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

	local r
	r=$(
		get_dtb |
		fdtget - "/chromeos/models/${model}${path}" "${prop}" \
		2>/dev/null
	)
	local ret=$?

	if [[ ${ret} -ne 0 && "${path}" =~ ^/firmware ]]; then
		# The value is missing; is it available at a firmware shares
		# phandle?
		local share
		share=$(get_dtb | fdtget - -f \
			"/chromeos/models/${model}/firmware" shares 2>/dev/null
		)

		if [[ $? -eq 0 ]]; then
			get_dtb | fdtget - \
			"${share}${path#/firmware}" "${prop}" 2>/dev/null
			return $?
		fi
	fi

	echo "${r}"
	return ${ret}
}
