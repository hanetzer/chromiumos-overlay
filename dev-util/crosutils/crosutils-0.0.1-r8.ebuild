# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="4903d4354ec32f0fa084fbbbdc0c4051b83929bb"

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
	local exclude_files="-e cros_make_image_bootable \
-e cros_sign_to_ssd -e cros_resign_image"
	local bin_files=$(ls bin/* | grep -v ${exclude_files})
	insinto /usr/lib/crosutils
	doins * || die "Could not install shared files."
	dolib lib/* || die "Could not install library files"
	dobin ${bin_files} || die "Could not install executable scripts."
}
