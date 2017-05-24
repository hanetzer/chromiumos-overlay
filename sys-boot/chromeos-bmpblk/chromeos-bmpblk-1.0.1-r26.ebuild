# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="2f616acb24a31c40b9e47a2d2e001a0a3b6d159e"
CROS_WORKON_TREE="3d67cdae6515e667b0fe994efa09e9ebcad9c30d"
CROS_WORKON_PROJECT="chromiumos/platform/bmpblk"
CROS_WORKON_LOCALNAME="../platform/bmpblk"
CROS_WORKON_OUTOFTREE_BUILD="1"
CROS_WORKON_USE_VCSID="1"

# TODO(hungte) When "tweaking ebuilds by source repository" is implemented, we
# can generate this list by some script inside source repo.
CROS_BOARDS=(
	auron_paine
	auron_yuna
	banjo
	buddy
	butterfly
	candy
	chell
	cid
	clapper
	cranky
	daisy
	daisy_snow
	daisy_spring
	daisy_spring-freon
	daisy_skate
	daisy_skate-freon
	daisy_freon
	enguarde
	expresso
	eve
	falco
	fizz
	glados
	glimmer
	gnawty
	guado
	kevin
	kip
	lars
	leon
	link
	lulu
	lumpy
	mccloud
	monroe
	ninja
	nyan
	nyan_big
	orco
	panther
	parrot
	peach_pi
	peach_pi-freon
	peach_pit
	peach_pit-freon
	peppy
	poppy
	quawks
	reks
	rikku
	soraka
	squawks
	stout
	stumpy
	sumo
	swanky
	tidus
	tricky
	veyron_brain
	veyron_danger
	veyron_jerry
	veyron_mickey
	veyron_minnie
	veyron_pinky
	veyron_romy
	winky
	wolf
	zako
)

inherit cros-workon cros-board

DESCRIPTION="Chrome OS Firmware Bitmap Block"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""
DEPEND="
	sys-apps/coreboot-utils
"

src_prepare() {
	export BOARD="$(get_current_board_with_variant "${ARCH}-generic")"
	export VCSID
}

src_compile() {
	emake OUTPUT="${WORKDIR}" "${BOARD}"
	emake OUTPUT="${WORKDIR}/${BOARD}" ARCHIVER="/usr/bin/archive" archive
}

doins_if_exist() {
	local f
	for f in "$@"; do
		if [[ -r "${f}" ]]; then
			doins "${f}"
		fi
	done
}

src_install() {
	# Bitmaps need to reside in the RO CBFS only. Many boards do
	# not have enough space in the RW CBFS regions to contain
	# all image files.
	insinto /firmware/rocbfs
	# These files aren't necessary for debug builds. When these files
	# are missing, Depthcharge will render text-only screens. They look
	# obviously not ready for release.
	doins_if_exist "${WORKDIR}/${BOARD}"/vbgfx.bin
	doins_if_exist "${WORKDIR}/${BOARD}"/locales
	doins_if_exist "${WORKDIR}/${BOARD}"/locale_*.bin
	doins_if_exist "${WORKDIR}/${BOARD}"/font.bin
}
