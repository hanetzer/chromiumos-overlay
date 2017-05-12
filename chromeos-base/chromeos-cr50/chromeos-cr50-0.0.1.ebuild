# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

DESCRIPTION="Ebuild to support the Chrome OS CR50 device."

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="h1_over_spi"

RDEPEND="chromeos-base/ec-utils"

CR50_NAME="cr50.r0.0.10.w0.0.18"
TARBALL_NAME="${CR50_NAME}.tbz2"
SRC_URI="gs://chromeos-localmirror/distfiles/${TARBALL_NAME}"
S="${WORKDIR}"

src_install() {
	local conffile="cr50-update.conf"

	insinto /opt/google/cr50/firmware
	newins "${CR50_NAME}"/*.bin.prod cr50.bin.prod
	newins "${CR50_NAME}"/*.bin.dev cr50.bin.dev

	insinto /etc/init
	if use h1_over_spi; then
		local tmpfile="${T}/copy"

		# Some platforms require using /dev/tpm0 instead of USB for
		# communicating with H1. Edit the startup file to address this
		# requirement.
		sed '/USB_UPDATER_DEFAULT_OPTIONS=/s:=:="-s":' \
			"${FILESDIR}/${conffile}" > "${tmpfile}" || \
			die "Failed to edit ${conffile}"
		newins "${tmpfile}" "${conffile}"
	else
		doins "${FILESDIR}/${conffile}"
	fi

	doins "${FILESDIR}"/cr50-result.conf

	exeinto /usr/share/cros
	doexe "${FILESDIR}"/cr50-update.sh
}
