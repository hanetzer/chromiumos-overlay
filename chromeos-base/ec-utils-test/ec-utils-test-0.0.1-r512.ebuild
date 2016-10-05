# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="e40fb3ef58a47d13418b2b6665026cf2ae5fd51e"
CROS_WORKON_TREE="01e45f73abd0bdac8b5d2cc62112598b96007017"
CROS_WORKON_PROJECT="chromiumos/platform/ec"
CROS_WORKON_LOCALNAME="ec"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_INCREMENTAL_BUILD=1

inherit cros-workon

DESCRIPTION="Chrome OS EC Utility Helper"

HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND="chromeos-base/ec-utils"

src_compile() {
	:
}

src_install() {
	dosbin "util/inject-keys.py"
}
