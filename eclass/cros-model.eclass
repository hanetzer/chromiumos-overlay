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

# @FUNCTION: cros-model_src_install_parent_config
# @DESCRIPTION:
# Copies all configuration files of parent model into folder of model.
cros-model_src_install_parent_config() {
	[[ $# -ne 2 ]] && die "Usage: ${FUNCNAME} <parent_model> <model>"

	local parent_model=$1
	local model=$2

	if [[ -n "${parent_model}" ]]; then
		# Avoid polluting callers with our newins.
		(
			insinto "${CROS_MODELS_DIR}/${model}"
			doins -r "${D}${CROS_MODELS_DIR}/${parent_model}"/*
		)
	fi
}

# @FUNCTION: cros-model_src_install_model_config
# @USAGE: <model>
# @DESCRIPTION:
# Copies all configuration files of model into CROS_MODELS_DIR and copies
# the model.dtsi to where cros-config expects it as input.
cros-model_src_install_model_config() {
	[[ $# -ne 1 ]] && die "Usage: ${FUNCNAME} <model>"

	local model=$1

	# Avoid polluting callers with our newins.
	(
		insinto "${CROS_MODELS_DIR}/${model}"
		doins -r "${FILESDIR}/${model}"/*

		# Could remove the file, but leaving it for now, so it's obvious in diff
		# if a different parent was used
		# rm "${D}${CROS_MODELS_DIR}/${model}/parent"

		# For the benefit of cros-config, put the model file where it expects it
		insinto "${UNIBOARD_DTS_DIR}"
		newins "${FILESDIR}/${model}/model.dtsi" "private-${model}.dtsi"
	)
}

# @FUNCTION: cros-model_src_install
# @DESCRIPTION:
# Copies all model configuration files to where they need to be.
cros-model_src_install() {
	local models=( $("${FILESDIR}/createInheritanceList.py" "${FILESDIR}") )

	local it
	for it in "${!models[@]}"; do
		local model="${models[it]#*/}"
		# The first model is the root and doesn't have a parent, so nothing to
		# copy from.
		if [[ ${it} -ne 0 ]]; then
			cros-model_src_install_parent_config "${models[it]%/*}" "${model}"
		fi
		cros-model_src_install_model_config "${model}"
	done

	# TODO(pberny): add private model copy on top
}

# @FUNCTION: cros-model_audio_configs_install
# @USAGE: <model> <portage_install_dir>
# @DESCRIPTION:
# Copy audio configuration files to where CRAS expects them to be.
cros-model_audio_configs_install() {
	[[ $# -ne 2 ]] && die "Usage: ${FUNCNAME} <model> <portage_install_dir>"

	# Install alsa config files.
	local model=$1
	local src_dir=$2
	local install_dir=$2

	local audio_config_dir="${src_dir}${CROS_MODELS_DIR}/${model}/Audio"

	local alsa_conf="${audio_config_dir}/alsa-module-config/alsa.conf"
	if [[ -f "${alsa_conf}" ]] ; then
		einfo "Installing ALSA config for ${model}"
		local modprobe_dir="${install_dir}etc/modprobe.d"
		mkdir -p "${modprobe_dir}"
		# This should never fail, since this models' config shouldn't be there.
		cp "${alsa_conf}" "${modprobe_dir}/alsa-${model}.conf" || die
	fi

	# Install alsa patch files.
	local alsa_patch="${audio_config_dir}/alsa-module-config/alsa.fw"
	if [[ -f "${alsa_patch}" ]] ; then
		einfo "Installing ALSA patch file for ${model}"
		local libfw_dir="${install_dir}lib/firmware"
		mkdir -p "${libfw_dir}"
		cp "${alsa_patch}" "${libfw_dir}/${model}_alsa.fw" || die
	fi

	# Install ucm config files.
	local ucm_config="${audio_config_dir}/ucm-config"
	if [[ -d "${ucm_config}" ]] ; then
		einfo "Installing ucm config for model ${model}"
		local ucm_config_dir="${install_dir}usr/share/alsa/ucm"
		mkdir -p "${ucm_config_dir}"
		# there should only be one conf ever. TODO assert if that's not true
		# for now just break out of loop
		local conf_file
		for conf_file in "${ucm_config}"/*.conf; do
			# Note that the .conf file must have the correct name matching
			# the audio card
			local audio_card_name="${conf_file%.conf}"
			audio_card_name="${audio_card_name##*/}"
			cp -r "${ucm_config}" "${ucm_config_dir}/${audio_card_name}.${model}" \
				|| die
			mv "${ucm_config_dir}/${audio_card_name}.${model}/${conf_file##*/}" \
				"${ucm_config_dir}/${audio_card_name}.${model}/${audio_card_name}.${model}.conf"
			break
		done

		# Fix up the submodels
		for sub in "${ucm_config}"/*; do
			if [[ -d "${sub}" ]]; then
				local submodel=${sub##*/}
				einfo "Installing ucm config for sku ${submodel}"
				cp -r "${ucm_config}/${submodel}" \
					"${ucm_config_dir}/${audio_card_name}.${model}.${submodel}" || die
				mv "${ucm_config_dir}/${audio_card_name}.${model}.${submodel}/${conf_file##*/}" \
				"${ucm_config_dir}/${audio_card_name}.${model}.${submodel}/${audio_card_name}.${model}.${submodel}.conf"
			fi
		done
	fi

	local cras_config="${audio_config_dir}/cras-config"
	if [[ -d "${cras_config}" ]] ; then
		local cras_config_dir="${install_dir}etc/cras"
		mkdir -p "${cras_config_dir}"
		cp -r "${cras_config}" "${cras_config_dir}/${model}" || die
		if [[ "${CROS_COMMON_MODEL}" == "${model}" ]]; then
			mv "${cras_config_dir}/${model}"/get_* "${cras_config_dir}"
		else
			rm "${cras_config_dir}/${model}"/get_*
		fi
	fi
}