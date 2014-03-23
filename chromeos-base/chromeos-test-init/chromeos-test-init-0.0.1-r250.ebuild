# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="12293dfb81ed434fe363a1585d2fb947c66f3192"
CROS_WORKON_TREE="9e9c7b31bccb0dc588f3fad0b442299257bca48c"
CROS_WORKON_PROJECT="chromiumos/platform/init"
CROS_WORKON_LOCALNAME="init"

inherit cros-workon

DESCRIPTION="Additional upstart jobs that will be installed on test images"
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD"
SLOT="0"
KEYWORDS="*"

src_install() {
	insinto /etc/init
	doins test-init/*.conf
}

