# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

DESCRIPTION="List of packages that should be fuzzed"
HOMEPAGE="http://dev.chromium.org/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	chromeos-base/midis[fuzzer]
	dev-util/bsdiff[fuzzer]
	dev-util/puffin[fuzzer]
"
