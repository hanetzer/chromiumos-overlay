# Copyright (c) 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: coreboot-private-files.eclass
# @MAINTAINER:
# The Chromium OS Authors
# @BLURB: Unifies logic for installing private coreboot files.

[[ ${EAPI} != "4" ]] && die "Only EAPI=4 is supported"

coreboot-private-files_src_install() {
	local srcdir="${1:-${FILESDIR}}"
	insinto /firmware/coreboot-private
	local file
	while read -d $'\0' -r file; do
		doins -r "${file}"
	done < <(find "${srcdir}" -maxdepth 1 -mindepth 1 -print0)
}

EXPORT_FUNCTIONS src_install
