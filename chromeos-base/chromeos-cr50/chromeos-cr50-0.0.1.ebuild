# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_BOARDS=( coral fizz scarlet soraka )
inherit cros-board

DESCRIPTION="Ebuild to support the Chrome OS CR50 device."

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND="chromeos-base/chromeos-cr50-scripts"

# There are two major types of images of Cr50, prod (used on most MP devices)
# and pre-pvt, used on devices still not fully released.
#
# Some boards can be using their custom Cr50 images, for those board the image
# name is overridden in the board's overlay chromeos-cr50 ebuild.
PROD_IMAGE="cr50.r0.0.10.w0.0.24"
PRE_PVT_IMAGE="cr50.r0.0.10.w0.0.26_FFFF_00000000_00000010"

# Let's make sure that both are pulled in and included in the manifest.
CR50_BASE_NAMES=( "${PROD_IMAGE}" "${PRE_PVT_IMAGE}" )
MIRROR_PATH="gs://chromeos-localmirror/distfiles/"
SRC_URI="$(printf " ${MIRROR_PATH}/%s.tbz2" "${CR50_BASE_NAMES[@]}")"

S="${WORKDIR}"

src_install() {
	local cr50_tarball_name

	if [[ -n "$(get_current_board_no_variant)" ]]; then
		cr50_tarball_name="${PRE_PVT_IMAGE}"
	else
		cr50_tarball_name="${PROD_IMAGE}"
	fi

	elog "Will install ${cr50_tarball_name}"

	insinto /opt/google/cr50/firmware
	newins "${cr50_tarball_name}"/*.bin.prod cr50.bin.prod
}
