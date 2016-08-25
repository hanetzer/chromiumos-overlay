# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

inherit cros-binary

DESCRIPTION="Ebuild to support the Chrome OS CR50 device."

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

CR50_NAME="cr50.r0.0.8.w0.0.5"
TARBALL_NAME="${CR50_NAME}.tbz2"
cros-binary_add_uri "gs://chromeos-localmirror/distfiles/${TARBALL_NAME}"
S="${DISTDIR}"

src_install() {
	CROS_BINARY_URI="${TARBALL_NAME}"
	cros-binary_src_install

	insinto /opt/google/cr50/firmware
	newins "${CR50_NAME}"/*.bin cr50.bin

	insinto /etc/init
	doins "${FILESDIR}"/*.conf
}



