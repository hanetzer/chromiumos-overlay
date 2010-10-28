# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="2"
CROS_WORKON_COMMIT="c0b696cf04ad2e309874d76d01423f06b0038fbb"

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
