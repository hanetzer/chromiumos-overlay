# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

#
# Original Author: The Chromium OS Authors <chromium-os-dev@chromium.org>
# Purpose: Library for handling building of ChromiumOS packages
#
#
#  This class provides an easy way to retrieve the BOARD variable.
#  It is intended to be used by ebuild packages that need to have the
#  board information for various reasons -- for example, to differentiate
#  various hardware attributes at build time.
#
#  If an unknown board is encountered and no default is provided, or multiple
#  boards are defined, this class deliberately fails the build.
#  This provides an easy method of identifying a change to
#  the build which might affect inheriting packages.

# Check for EAPI 4+
case "${EAPI:-0}" in
4|5|6) ;;
*) die "unsupported EAPI (${EAPI}) in eclass (${ECLASS})" ;;
esac

BOARD_USE_PREFIX="board_use_"

# Obsolete boards' names are commented-out but retained in this list so
# they won't be accidentally recycled in the future.
ALL_BOARDS=(
	acorn
	amd64-corei7
	#amd64-drm
	amd64-generic
	amd64-generic_embedded
	#amd64-generic_freon
	amd64-generic-goofy
	amd64-generic_mobbuild
	amd64-host
	#anglar
	aplrvp
	#app-shell-panther
	aries
	arkham
	arm-generic
	arm-generic_freon
	arm64-generic
	auron
	auron_paine
	auron_pearlvalley
	auron_yuna
	banjo
	bayleybay
	beaglebone
	beaglebone_servo
	beaglebone_vv1
	beltino
	blackwall
	bobcat
	bolt
	bruteus
	buddy
	#buranku
	butterfly
	bwtm2
	#bxt-rvp
	candy
	cardhu
	celes
	chell
	#chronos
	cid
	clapper
	cosmos
	cranky
	cyan
	cyan-cheets
	cyclone
	daisy
	#daisy-drm
	daisy_embedded
	daisy_snow
	daisy_skate
	daisy_spring
	daisy_winter
	dalmore
	danger
	danger_embedded
	#derwent
	duck
	edgar
	#emeraldlake2
	enguarde
	envoy-jerry
	expresso
	falco
	falco_gles
	falco_li
	fb1
	foster
	#fox
	#fox_baskingridge
	#fox_wtm1
	#fox_wtm2
	gale
	gandof
	gizmo
	glados
	glados-cheets
	glimmer
	gnawty
	gru
	guado
	guado_moblab
	heli
	hsb
	ironhide
	#jaguar
	jecht
	kayle
	kblrvp
	#kennet
	kevin
	#kiev
	kip
	klang
	kunimitsu
	lakitu
	lakitu_mobbuild
	lakitu_next
	lars
	laser
	#lemmings
	#lemmings_external
	leon
	link
	lulu
	lumpy
	mappy
	mappy-envoy
	mappy_flashstation
	marble
	mccloud
	minnowboard
	mipseb-o32-generic
	mipseb-n32-generic
	mipseb-n64-generic
	mipsel-o32-generic
	mipsel-n32-generic
	mipsel-n64-generic
	monroe
	moose
	ninja
	nyan
	nyan_big
	nyan_blaze
	nyan_freon
	nyan_kitty
	oak
	oak-cheets
	optimus
	orco
	panda
	panther
	panther_embedded
	panther_goofy
	panther_moblab
	parrot
	parrot_ivb
	parrot32
	parrot64
	#parry
	peach
	peach_kirby
	peach_pi
	peach_pit
	pedra
	peppy
	ppcbe-32-generic
	ppcbe-64-generic
	ppcle-32-generic
	ppcle-64-generic
	puppy
	purin
	quawks
	rambi
	raspberrypi
	reks
	reptile
	#ricochet
	rikku
	rizer
	rotor
	rush
	rush_ryu
	sama5d3
	samus
	samus-cheets
	sentry
	setzer
	shogun
	sklrvp
	slippy
	smaug
	smaug-cheets
	sonic
	#space
	squawks
	storm
	storm_nand
	stout
	#stout32
	strago
	stumpy
	stumpy_moblab
	stumpy_pico
	sumo
	swanky
	tails
	#tegra2
	#tegra2_aebl
	#tegra2_arthur
	#tegra2_asymptote
	#tegra2_dev-board
	#tegra2_dev-board-opengl
	#tegra2_kaen
	#tegra2_seaboard
	#tegra2_wario
	tegra3-generic
	terra
	tidus
	tricky
	ultima
	umaro
	#urara
	veyron
	veyron_brain
	veyron_caution
	veyron_danger
	veyron_emile
	veyron_gus
	veyron_jaq
	veyron_jerry
	veyron_mickey
	veyron_mighty
	veyron_minnie
	veyron_minnie-cheets
	veyron_nicky
	veyron_pinky
	veyron_remy
	veyron_romy
	veyron_rialto
	veyron_shark
	veyron_speedy
	veyron_thea
	#waluigi
	whirlwind
	winky
	wizpig
	wolf
	wsb
	x32-generic
	x86-agz
	x86-alex
	x86-alex_he
	x86-alex_hubble
	x86-alex32
	x86-alex32_he
	x86-dogfood
	#x86-drm
	#x86-fruitloop
	x86-generic
	x86-generic_embedded
	#x86-generic_freon
	x86-mario
	x86-mario64
	#x86-pineview
	#x86-wayland
	x86-zgb
	x86-zgb_he
	x86-zgb32
	x86-zgb32_he
	zako
)

# Use the CROS_BOARDS defined by ebuild, otherwise use ALL_BOARDS.
if [[ ${#CROS_BOARDS[@]} -eq 0 ]]; then
	CROS_BOARDS=( "${ALL_BOARDS[@]}" )
fi

# Add BOARD_USE_PREFIX to each board in ALL_BOARDS to create IUSE.
# Also add cros_host so that we can inherit this eclass in ebuilds
# that get emerged both in the cros-sdk and for target boards.
# See REQUIRED_USE below.
IUSE="${CROS_BOARDS[@]/#/${BOARD_USE_PREFIX}} cros_host"

# Echo the current board, with variant.
get_current_board_with_variant()
{
	[[ $# -gt 1 ]] && die "Usage: ${FUNCNAME} [default]"

	local b
	local current
	local default_board=$1

	for b in "${CROS_BOARDS[@]}"; do
		if use ${BOARD_USE_PREFIX}${b}; then
			if [[ -n "${current}" ]]; then
				die "More than one board is set: ${current} and ${b}"
			fi
			current="${b}"
		fi
	done

	if [[ -n "${current}" ]]; then
		echo ${current}
		return
	fi

	echo "${default_board}"
}

# Echo the current board, without variant.
get_current_board_no_variant()
{
	get_current_board_with_variant "$@" | cut -d '_' -f 1
}
