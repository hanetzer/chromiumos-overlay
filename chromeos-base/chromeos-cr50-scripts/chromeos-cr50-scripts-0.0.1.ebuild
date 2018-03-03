# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit udev

DESCRIPTION="Ebuild to support the Chrome OS Cr50 device."

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	chromeos-base/ec-utils
	!<chromeos-base/chromeos-cr50-0.0.1-r38
"

S="${WORKDIR}"

src_install() {
	local cros_files
	local f

	insinto /etc/init
	doins "${FILESDIR}/"cr50-update.conf
	doins "${FILESDIR}"/cr50-result.conf

	udev_dorules "${FILESDIR}"/99-cr50.rules

	exeinto /usr/share/cros
	cros_files=(
		cr50-get-name.sh
		cr50-reset.sh
		cr50-set-board-id.sh
		cr50-update.sh
		cr50-verify-ro.sh
	)
	for f in "${cros_files[@]}"; do
		doexe "${FILESDIR}/${f}"
	done

	insinto /opt/google/cr50/ro_db
	doins "${FILESDIR}"/verify_ro.db
}
