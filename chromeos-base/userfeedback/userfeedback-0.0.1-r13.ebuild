# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="2"
CROS_WORKON_COMMIT="29c40c8e66aa8d3f835bbc8e742cc081ffe95edf"

inherit cros-workon

DESCRIPTION="Log scripts used by userfeedback to report cros system information"
HOMEPAGE="http://www.chromium.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="arm x86"
IUSE=""

RDEPEND=""

DEPEND="${RDEPEND}"

src_install() {
	exeinto /usr/share/userfeedback/scripts
	doexe scripts/* || die "Could not copy scripts"

	insinto /usr/share/userfeedback/etc
	doins etc/* || die "Could not copy etc"
}
