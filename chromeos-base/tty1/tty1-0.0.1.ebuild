# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

DESCRIPTION="Init script to run agetty on VT1.  For use in headless builds."

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="+vt"

RDEPEND="
	sys-apps/upstart
"

# Because this ebuild has no source package, "${S}" doesn't get
# automatically created.  The compile phase depends on "${S}" to
# exist, so we make sure "${S}" refers to a real directory.
#
# The problem is apparently an undocumented feature of EAPI 4;
# earlier versions of EAPI don't require this.
S="${WORKDIR}"

src_install() {
	if use vt ; then
		insinto /etc/init
		doins "${FILESDIR}"/tty1.conf
	fi
}
