# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="1f4483c10b2bd5f0bcd81ce326179a9fd64268ad"
CROS_WORKON_PROJECT="chromiumos/platform/factory-utils"

inherit cros-workon

DESCRIPTION="Factory development utilities for ChromiumOS"
HOMEPAGE="http://www.chromium.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="cros_factory_bundle"

CROS_WORKON_LOCALNAME="factory-utils"
RDEPEND=""

# chromeos-installer for solving "lib/chromeos-common.sh" symlink.
# vboot_reference for binary programs (ex, cgpt).
DEPEND="chromeos-base/chromeos-installer[cros_host]
        chromeos-base/vboot_reference"

replace_link() {
	local link="$1"
	local prefix="$2"
	local src="${CROS_WORKON_SRCROOT}/src/platform/${CROS_WORKON_LOCALNAME}"
	local relative_path="${link#$prefix}"

	rm "${link}" || die "Failed to remove ${link}"
	cp -fL "${src}/${relative_path}" "${link}" ||
		die "Failed to replace ${link}"
}

# TODO(hungte) Move all the complex compile/install procedure into a Makefile in
# source tree.
src_compile() {
	# Convert symbolic links into real files for installation.
	local link
	for link in $(find "${S}" -type l); do
		replace_link "${link}" "${S}"
	done

	# Copy binary programs.
	# TODO(hungte) We should avoid binary programs, and prevent pulling
	# files from chroot (or other packages). Rewrite cgpt in portable way
	# (ex, python) or make some special param for vboot_reference to take
	# care of installing it into the right place.
	local bin_dir="${S}/factory_setup/bin"
	mkdir -p "${bin_dir}"
	cp -f /usr/bin/cgpt "${bin_dir}" || die "Failed to copy 'cgpt'"
}

src_install() {
	# Installation for factory_setup scripts.
	local src=factory_setup
	local dest=/usr/share/cros-factoryutils/factory_setup

	if use cros_factory_bundle; then
		einfo "Building factory bundle."
		dest=/factory_setup
	else
		# TODO(hungte) Remove this after make_netboot.sh uses new path.
		dobin factory_setup/update_firmware_vars.py
	fi

	insinto "${dest}"
	doins -r "${src}"/lib
	exeinto "${dest}"
	doexe "${src}"/*.{py,sh}
	exeinto "${dest}"/bin
	doexe "${src}"/bin/*
}
