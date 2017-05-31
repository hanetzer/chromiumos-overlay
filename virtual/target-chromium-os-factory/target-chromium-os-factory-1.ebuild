# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

DESCRIPTION="List of packages that are needed inside the Chromium OS factory
image."
HOMEPAGE="http://dev.chromium.org/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

DEPEND="!chromeos-base/chromeos-factory"
RDEPEND="
	chromeos-base/chromeos-hwid
	chromeos-base/factory
	${DEPEND}
"
