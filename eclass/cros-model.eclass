# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# @ECLASS:cros-model.eclass
# @BLURB: helper eclass for installing a model's config files.
# @DESCRIPTION:
# This eclass provides an easy way to install model related config files.
# It is intended for use by chromeos-config-<models>-<board_name> ebuilds.

inherit cros-audio-configs cros-unibuild

# @ECLASS-VARIABLE: CROS_MODELS_DIR
# @DESCRIPTION:
#  This is the installation directory of the model's config files.
CROS_MODELS_DIR="/usr/share/models"

# @ECLASS-VARIABLE: CROS_COMMON_MODEL
# @DESCRIPTION:
#  This is the name of the shared configuration model. It is simply a helper
#  for the inheritance of configurations, not a real model.
CROS_COMMON_MODEL="common"

# @ECLASS-VARIABLE: CROS_MODEL_PRIVATE
# @DESCRIPTION:
#  This is the subdirectory name for private config files.
CROS_MODEL_PRIVATE="private"

# @FUNCTION: cros-model_src_install_parent_config
# @DESCRIPTION:
# Copies all configuration files of parent model into folder of model.
cros-model_src_install_parent_config() {
	[[ $# -ne 3 ]] && die "Usage: ${FUNCNAME} <parent_model> <model>" \
		"<${CROS_MODEL_PRIVATE} or empty string>"

	local parent_model="$1"
	local model="$2"
	local private="$3"

	if [[ -n "${parent_model}" ]]; then
		# Avoid polluting callers with our newins.
		(
			einfo "Installing parent ${parent_model} config files"
			if [[ ${#private} -ne 0 ]]; then
				insinto "${CROS_MODELS_DIR}/${model}/${private}"
				doins -r "${D}${CROS_MODELS_DIR}/${parent_model}/${private}"/*
			else
				insinto "${CROS_MODELS_DIR}/${model}"
				doins -r "${D}${CROS_MODELS_DIR}/${parent_model}"/*
			fi
		)
	fi
}

# @FUNCTION: cros-model_src_install_model_config
# @USAGE: <model>
# @DESCRIPTION:
# Copies all configuration files of model into CROS_MODELS_DIR and copies
# the model.dtsi to where cros-config expects it as input.
cros-model_src_install_model_config() {
	[[ $# -ne 2 ]] && die \
		"Usage: ${FUNCNAME} <model> <${CROS_MODEL_PRIVATE} or empty string>"

	local model="$1"
	local private="$2"

	# Avoid polluting callers with our newins.
	(
		einfo "Installing ${model} ${private} config files"
		einfo ""
		if [[ ${#private} -ne 0 ]]; then
				insinto "${CROS_MODELS_DIR}/${model}/${private}"
		else
				insinto "${CROS_MODELS_DIR}/${model}"
		fi
		[[ -d "${FILESDIR}/${model}" ]] && doins -r "${FILESDIR}/${model}"/*

		# Could remove the file, but leaving it for now, so it's obvious in diff
		# if a different parent was used
		# rm "${D}${CROS_MODELS_DIR}/${model}/parent"
	)
}

# @FUNCTION: _cros-model_src_install
# @DESCRIPTION:
# Copies all model configuration files to where they need to be.
_cros-model_src_install() {
	[[ $# -ne 1 ]] && die "Usage: ${FUNCNAME} <${CROS_MODEL_PRIVATE} or empty string>"

	local private="$1"
	local root_dir="${SYSROOT%/}${CROS_MODELS_DIR}"

	# It makes the code in the board's chromeos-bsp-<board>.ebuild a bit simpler
	# and to make it easier to migrate in phases, this needs to be supported, as
	# otherwise we'll have broken builds from the boards that have not done the
	# split into public/private yet.
	# It might be even cleaner if we offered a helper function that users of
	# cros-model.eclass can use to iterate over models instead of doing it
	# themselves based on the directory structure.
	if [[ ${#private} -eq 0 ]]; then
		root_dir="${FILESDIR}"
	fi

	local models=( $("${root_dir}/createInheritanceList.py" \
		"${SYSROOT%/}${CROS_MODELS_DIR}") )

	einfo $models
	local it
	for it in "${!models[@]}"; do
		local model="${models[it]#*/}"
		# The first model is the root and doesn't have a parent, so nothing to
		# copy from.
		if [[ ${it} -ne 0 ]]; then
			cros-model_src_install_parent_config "${models[it]%/*}" "${model}" \
				"${private}"
		fi
		cros-model_src_install_model_config "${model}" "${private}"
	done
}

# @FUNCTION: cros-model_src_install
# @DESCRIPTION:
# Copies all model configuration files to where they need to be.
cros-model_src_install() {
	_cros-model_src_install ""
}

# @FUNCTION: cros-model_private_src_install
# @DESCRIPTION:
# Copies all private model configuration files to where they need to be.
cros-model_private_src_install() {
	_cros-model_src_install "${CROS_MODEL_PRIVATE}"
}
