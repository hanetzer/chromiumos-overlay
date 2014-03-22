# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="3dc182e1ba83da9cd23dcc01cd0470ac9d0eff78"
CROS_WORKON_TREE="734581448a550114e4a30ada3ef0ee47cfa961f7"
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

