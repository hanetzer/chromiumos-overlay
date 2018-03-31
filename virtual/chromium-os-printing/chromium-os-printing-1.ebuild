# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

DESCRIPTION="List of packages required for the Chromium OS Printing subsystem"
HOMEPAGE="http://dev.chromium.org/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

IUSE="postscript"

RDEPEND="
	net-print/cups
	net-print/cups-filters
	postscript? ( net-print/hplip )
"
