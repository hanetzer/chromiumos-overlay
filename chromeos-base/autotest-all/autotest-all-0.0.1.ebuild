# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="2"

DESCRIPTION="Meta ebuild for all packages providing tests"
HOMEPAGE="http://www.chromium.org"

LICENSE="GPL-2"
SLOT=0
KEYWORDS="amd64 x86 arm"
IUSE=""

RDEPEND="
	chromeos-base/autotest-tests
	chromeos-base/autotest-private
"

DEPEND="${RDEPEND}"
