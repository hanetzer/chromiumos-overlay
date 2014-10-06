# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
# $Header: $

# @ECLASS: osreleased.eclass
# @MAINTAINER:
# Chromium OS build team;
# @BUGREPORTS:
# Please report bugs via http://crbug.com/new (with label Build)
# @VCSURL: https://chromium.googlesource.com/chromiumos/overlays/chromiumos-overlay/+/master/eclass/@ECLASS@
# @BLURB: Eclass for setting fields in /etc/os-release.d/

# @FUNCTION: do_osrelease_field
# @USAGE: <field_name> <field_value>
# @DESCRIPTION:
# Creates a file named /etc/os-release.d/<file_name> containing <field_value>.
# All files in os-release.d will be combined to create /etc/os-release when
# building the image.
do_osrelease_field() {
	[[ $# -eq 2 && -n $1 && -n $2 ]] || die "Usage: ${FUNCNAME} <field_name> <field_value>"
	local namevalidregex="[_A-Z]+"
	local valuevalidregex="[^\n]+"

	local field_name="$1"
	local field_value="$2"

	local filtered_name=$(echo "${field_name}" |\
		LC_ALL=C sed -r "s:${namevalidregex}::")
	local number_lines=$(echo "${field_value}" | wc -l)
	if [[ -n "${filtered_name}" ]]; then
		die "Invalid input. Field name must satisfy: ${validregex}"
	fi
	if [[ "${number_lines}" != "1" ]]; then
		die "Invalid input. Field value must not contain new lines."
	fi
	dodir /etc/os-release.d

	local field_file="${D}/etc/os-release.d/${field_name}"
	[[ -e ${field_file} ]] && die "The field ${field_name} has already been set!"
	echo "${field_value}" > "${field_file}" || \
		die "creating ${os_release} failed!"
}
