# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

DESCRIPTION="Chrome OS u-boot virtual package"
HOMEPAGE="http://src.chromium.org"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 arm"
IUSE="-u_boot_next"

RDEPEND="
	u_boot_next? ( sys-boot/chromeos-u-boot-next )
	!u_boot_next? ( sys-boot/chromeos-u-boot )
"
