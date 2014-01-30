# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

DESCRIPTION="Chrome OS virtual ModemManager package"
HOMEPAGE="http://src.chromium.org"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

DEPEND="
	net-misc/modemmanager-next
	net-misc/modemmanager-classic-interfaces
"
RDEPEND="${DEPEND}"
