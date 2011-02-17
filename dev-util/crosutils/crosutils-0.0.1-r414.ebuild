# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="c5ae0344d2efbefbefc5daf9a1144d278dd08cc3"

inherit cros-workon

DESCRIPTION="Chromium OS build utilities"
HOMEPAGE="http://www.chromium.org/chromium-os"
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

DEPEND=""
RDEPEND="dev-libs/shflags"

CROS_WORKON_LOCALNAME="../scripts/"

src_configure() {
	find . -type l -exec rm {} \; &&
	rm -fr WATCHLISTS inherit-review-settings-ok lib/shflags ||
		die "Couldn't clean directory."
}

src_install() {
	# Install package files
	exeinto /usr/lib/crosutils
	doexe * || die "Could not install shared files."

	# Install python libraries into site-packages
	local python_version=$(/usr/bin/env python -c \
	      "import sys; print sys.version[:3]")
	insinto /usr/lib/python"${python_version}"/site-packages
	doins lib/*.py || die "Could not install python files."
	rm -f lib/*.py

	# Install libraries
	insinto /usr/lib/crosutils/lib
	doins lib/* || die "Could not install library files"

	# Install binaries
	local exclude_files="\
		-e cros_make_image_bootable \
		-e cros_sign_to_ssd \
		-e cros_resign_image \
		-e cros_overlay_list
		"

	local bin_files=$(ls bin/* | grep -v ${exclude_files})
	dobin ${bin_files} || die "Could not install executable scripts."
	dosym loman.py /usr/bin/loman
}
