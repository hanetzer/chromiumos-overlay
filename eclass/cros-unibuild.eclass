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

# We require that CROS_BOARD be defined to avoid using ALL_BOARDS here.
[[ "${#CROS_BOARDS[@]}" -eq 1 ]] || die "uniboard eclass requires CROS_BOARDS"

# We don't need need functions if there is no board.
if [[ "${CROS_BOARDS}" != "none" ]]; then

inherit cros-board

# @FUNCTION: install_model_file
# @USAGE:
# @DESCRIPTION:
# Installs the .dtsi file for the current board. This is called from the
# chromeos-config-<board> public ebuild. It is named "<board>-model.dtsi".
install_model_file() {
	[[ $# -eq 0 ]] || die "${FUNCNAME}: takes no arguments"

	local board="$(get_current_board_no_variant)"
	local dest="${board}-model.dtsi"

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
# "<board>-model.dtsi".
install_private_model_file() {
	[[ $# -eq 0 ]] || die "${FUNCNAME}: takes no arguments"

	local board="$(get_current_board_no_variant)"
	local dest="${board}-private-model.dtsi"

	einfo "Installing ${dest} to ${UNIBOARD_DTS_DIR}"

	# Avoid polluting callers with our insinto.
	(
		insinto "${UNIBOARD_DTS_DIR}"
		newins ${FILESDIR}/model.dtsi "${dest}"
	)
}

# @FUNCTION: get_model_conf_value
# @USAGE: <model> <path> <prop>
# @DESCRIPTION:
# Obtain a configuration value for a given model.
# @RETURN: value of the property, or empty if not found, in which
# case the return code indicates failure.
# @CODE
# model name of model to lookup.
# @CODE
# path path to config string, e.g. "/".
# @CODE
# @prop name of property to read (e.g. "wallpaper").
get_model_conf_value() {
	[[ $# -eq 3 ]] || die "${FUNCNAME}: takes 3 arguments"

	local model="$1"
	local path="$2"
	local prop="$3"
	fdtget "${ROOT}${UNIBOARD_DTB_INSTALL_PATH}" \
		"/chromeos/models/${model}${path}" "${prop}" 2>/dev/null
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
# model name of model to lookup.
# @CODE
# path path to config string, e.g. "/".
# @CODE
# @prop name of property to read (e.g. "wallpaper").
get_model_conf_value_noroot() {
	[[ $# -eq 3 ]] || die "${FUNCNAME}: takes 3 arguments"

	# This function is called before FILESDIR is set so figure it out from
	# the ebuild filename.
	local filesdir="$(dirname "${EBUILD}")/files"

	local model="$1"
	local path="$2"
	local prop="$3"

	# We are not allowed to access the ROOT directory here, so compile the
	# model fragment on the fly and pull out the value we want.
	echo "/dts-v1/; / { chromeos { models: models { }; }; };" |
		cat - "${filesdir}/model.dtsi" |
		dtc -O dtb |
		fdtget - "/chromeos/models/${model}${path}" "${prop}" \
			2>/dev/null
}

fi
