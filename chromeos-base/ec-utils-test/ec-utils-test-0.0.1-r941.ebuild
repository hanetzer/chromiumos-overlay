# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="64d79d609bb2bd66a05bb96b2714543bed667c67"
CROS_WORKON_TREE="9a2e165e31a6c70226a754504356f99d85a1c830"
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
