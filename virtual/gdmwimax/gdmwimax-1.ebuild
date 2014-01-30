# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

DESCRIPTION="Virtual package for GCT GDM7205 WiMAX SDK"
HOMEPAGE="http://www.gctsemi.com/"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="internal"

DEPEND="
	internal? ( net-wireless/gdmwimax-private )
	!internal? ( net-wireless/gdmwimax )
"
RDEPEND="${DEPEND}"
