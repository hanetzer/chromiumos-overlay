# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="691f22dccd0d43ae659bdfa33c6c8a1528f7e8e9"
CROS_WORKON_TREE="b4182c2b2dbef7295f3d727e1bb33bbb0d828c1c"
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

