# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="77b3d1edea7d776a34d8dbf3a09e3a72f3e4802f"
CROS_WORKON_TREE="77d1382e47171063c3ee03292916ad5ede9a7288"
CROS_WORKON_PROJECT="chromiumos/platform/assets"

inherit cros-workon toolchain-funcs

DESCRIPTION="Common Chromium OS assets (images, sounds, etc.)"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="alex lumpy lumpy64 mario tegra2-ldk"

DEPEND=""
# display_boot_message calls ply-image directly.

RDEPEND="!<chromeos-base/chromeos-assets-0.0.2"

RDEPEND+="
	chromeos-base/chromeos-fonts
	media-gfx/ply-image"

REAL_CURSOR_NAMES="
	fleur
	hand2
	left_ptr
	sb_h_double_arrow
	sb_v_double_arrow
	top_left_corner
	top_right_corner
	xterm"

# These are cursors for which there is no file, but we want to use
# one of the existing files.  So we link them.  The first one is an
# X holdover from some mozilla bug, and without it, we will use the
# default left_ptr_watch bitmap.
LINK_CURSORS="
	08e8e1c95fe2fc01f976f1e063a24ccd:left_ptr_watch
	X_cursor:left_ptr
	arrow:left_ptr
	based_arrow_down:sb_v_double_arrow
	based_arrow_up:sb_v_double_arrow
	boat:left_ptr
	bogosity:left_ptr
	bottom_left_corner:top_right_corner
	bottom_right_corner:top_left_corner
	bottom_side:sb_v_double_arrow
	bottom_tee:sb_v_double_arrow
	box_spiral:left_ptr
	center_ptr:left_ptr
	circle:left_ptr
	clock:left_ptr
	coffee_mug:left_ptr
	diamond_cross:left_ptr
	dot:left_ptr
	dotbox:left_ptr
	double_arrow:sb_v_double_arrow
	draft_large:left_ptr
	draft_small:left_ptr
	draped_box:left_ptr
	exchange:left_ptr
	gobbler:left_ptr
	gumby:left_ptr
	hand1:hand2
	heart:left_ptr
	icon:left_ptr
	iron_cross:left_ptr
	left_ptr_watch:left_ptr
	left_side:sb_h_double_arrow
	left_tee:sb_h_double_arrow
	leftbutton:left_ptr
	ll_angle:top_right_corner
	lr_angle:top_left_corner
	man:left_ptr
	middlebutton:left_ptr
	mouse:left_ptr
	pencil:left_ptr
	pirate:left_ptr
	plus:left_ptr
	right_ptr:left_ptr
	right_side:sb_h_double_arrow
	right_tee:sb_h_double_arrow
	rightbutton:left_ptr
	rtl_logo:left_ptr
	sailboat:left_ptr
	sb_down_arrow:sb_v_double_arrow
	sb_left_arrow:sb_h_double_arrow
	sb_right_arrow:sb_h_double_arrow
	sb_up_arrow:sb_v_double_arrow
	shuttle:left_ptr
	sizing:top_left_corner
	spider:left_ptr
	spraycan:left_ptr
	star:left_ptr
	target:left_ptr
	tcross:left_ptr
	top_left_arrow:left_ptr
	top_side:sb_v_double_arrow
	top_tee:sb_v_double_arrow
	trek:left_ptr
	ul_angle:top_left_corner
	umbrella:left_ptr
	ur_angle:top_right_corner
	watch:left_ptr"

CROS_WORKON_LOCALNAME="assets"

src_install() {
	insinto /usr/share/chromeos-assets/images
	doins -r "${S}"/images/*

	insinto /usr/share/chromeos-assets/images_100_percent
	doins -r "${S}"/images_100_percent/*

	insinto /usr/share/chromeos-assets/images_200_percent
	doins -r "${S}"/images_200_percent/*

	insinto /usr/share/chromeos-assets/text
	doins -r "${S}"/text/boot_messages
	dosbin "${S}"/text/display_boot_message

	insinto /usr/share/chromeos-assets/gaia_auth
	doins -r "${S}"/gaia_auth/*

	insinto /usr/share/chromeos-assets/input_methods
	doins "${S}"/input_methods/*

	mkdir "${S}"/connectivity_diagnostics_launcher_deploy
	pushd "${S}"/connectivity_diagnostics_launcher_deploy > /dev/null
	unpack ./../connectivity_diagnostics_launcher/connectivity_diagnostics_launcher.zip
	insinto /usr/share/chromeos-assets/connectivity_diagnostics_launcher
	doins -r "${S}"/connectivity_diagnostics_launcher_deploy/*
	popd > /dev/null

	mkdir "${S}"/connectivity_diagnostics_deploy
	unzip "${S}"/connectivity_diagnostics/connectivity_diagnostics.zip \
		-d "${S}"/connectivity_diagnostics_deploy
	insinto /usr/share/chromeos-assets/connectivity_diagnostics
	doins -r "${S}"/connectivity_diagnostics_deploy/*

	mkdir "${S}"/connectivity_diagnostics_kiosk_deploy
	unzip "${S}"/connectivity_diagnostics/connectivity_diagnostics_kiosk.zip \
		-d "${S}"/connectivity_diagnostics_kiosk_deploy
	insinto /usr/share/chromeos-assets/connectivity_diagnostics_kiosk
	doins -r "${S}"/connectivity_diagnostics_kiosk_deploy/*

	insinto /usr/share/chromeos-assets/crosh_builtin/
	unzip -d crosh_builtin_deploy/ "${S}"/chromeapps/crosh_builtin/crosh_builtin.zip

	doins -r "${S}"/crosh_builtin_deploy/*

	insinto /usr/share/color/bin
	if use mario; then
		newins "${S}"/color_profiles/mario.bin internal_display.bin
	elif use alex; then
		newins "${S}"/color_profiles/alex.bin internal_display.bin
	elif use lumpy; then
		newins "${S}"/color_profiles/lumpy.bin internal_display.bin
	fi

	# Don't install cursors when building for Tegra, since the
	# current ARGB cursor implementation is performing badly,
	# and the fallback to 2-bit hardware cursor works better.
	# TODO: Remove this when the display driver has been fixed to
	# remove the performance bottlenecks.
	if ! use tegra2-ldk; then
		local CURSOR_DIR="${D}"/usr/share/cursors/xorg-x11/chromeos/cursors

		mkdir -p "${CURSOR_DIR}"
		for i in ${REAL_CURSOR_NAMES}; do
			xcursorgen -p "${S}"/cursors "${S}"/cursors/$i.cfg >"${CURSOR_DIR}/$i"
		done

		for i in ${LINK_CURSORS}; do
			ln -s ${i#*:} "${CURSOR_DIR}/${i%:*}"
		done
	fi

	mkdir -p "${D}"/usr/share/cursors/xorg-x11/default
	echo Inherits=chromeos \
		>"${D}"/usr/share/cursors/xorg-x11/default/index.theme

	#
	# Speech synthesis
	#

	insinto /usr/share/chromeos-assets/speech_synthesis/patts

	# Speech synthesis component extension code
	doins "${S}"/speech_synthesis/patts/manifest.json
	doins "${S}"/speech_synthesis/patts/tts_main.js
	doins "${S}"/speech_synthesis/patts/tts_controller.js
	doins "${S}"/speech_synthesis/patts/tts_service.nmf

	# Speech synthesis voice data
	doins "${S}"/speech_synthesis/patts/voice_data_hmm_de-DE_2.js
	unzip "${S}"/speech_synthesis/patts/voice_data_hmm_de-DE_2.zip
	doins -r "${S}"/voice_data_hmm_de-DE_2
	doins "${S}"/speech_synthesis/patts/voice_data_hmm_en-GB_2.js
	unzip "${S}"/speech_synthesis/patts/voice_data_hmm_en-GB_2.zip
	doins -r "${S}"/voice_data_hmm_en-GB_2
	doins "${S}"/speech_synthesis/patts/voice_data_hmm_en-IN_2.js
	unzip "${S}"/speech_synthesis/patts/voice_data_hmm_en-IN_2.zip
	doins -r "${S}"/voice_data_hmm_en-IN_2
	doins "${S}"/speech_synthesis/patts/voice_data_hmm_en-US_2.js
	unzip "${S}"/speech_synthesis/patts/voice_data_hmm_en-US_2.zip
	doins -r "${S}"/voice_data_hmm_en-US_2
	doins "${S}"/speech_synthesis/patts/voice_data_hmm_es-ES_2.js
	unzip "${S}"/speech_synthesis/patts/voice_data_hmm_es-ES_2.zip
	doins -r "${S}"/voice_data_hmm_es-ES_2
	doins "${S}"/speech_synthesis/patts/voice_data_hmm_es-US_2.js
	unzip "${S}"/speech_synthesis/patts/voice_data_hmm_es-US_2.zip
	doins -r "${S}"/voice_data_hmm_es-US_2
	doins "${S}"/speech_synthesis/patts/voice_data_hmm_fr-FR_2.js
	unzip "${S}"/speech_synthesis/patts/voice_data_hmm_fr-FR_2.zip
	doins -r "${S}"/voice_data_hmm_fr-FR_2
	doins "${S}"/speech_synthesis/patts/voice_data_hmm_it-IT_2.js
	unzip "${S}"/speech_synthesis/patts/voice_data_hmm_it-IT_2.zip
	doins -r "${S}"/voice_data_hmm_it-IT_2
	doins "${S}"/speech_synthesis/patts/voice_data_hmm_ko-KR_2.js
	unzip "${S}"/speech_synthesis/patts/voice_data_hmm_ko-KR_2.zip
	doins -r "${S}"/voice_data_hmm_ko-KR_2
	doins "${S}"/speech_synthesis/patts/voice_data_hmm_nl-NL_2.js
	unzip "${S}"/speech_synthesis/patts/voice_data_hmm_nl-NL_2.zip
	doins -r "${S}"/voice_data_hmm_nl-NL_2
	doins "${S}"/speech_synthesis/patts/voice_data_hmm_pt-BR_2.js
	unzip "${S}"/speech_synthesis/patts/voice_data_hmm_pt-BR_2.zip
	doins -r "${S}"/voice_data_hmm_pt-BR_2

	# Speech synthesis engine (platform-specific native client module)
	if use arm ; then
		unzip "${S}"/speech_synthesis/patts/tts_service_arm.nexe.zip
		doins "${S}"/tts_service_arm.nexe
	elif use x86 ; then
		unzip "${S}"/speech_synthesis/patts/tts_service_x86-32.nexe.zip
		doins "${S}"/tts_service_x86-32.nexe
	elif use amd64 ; then
		unzip "${S}"/speech_synthesis/patts/tts_service_x86-64.nexe.zip
		doins "${S}"/tts_service_x86-64.nexe
	fi
}
