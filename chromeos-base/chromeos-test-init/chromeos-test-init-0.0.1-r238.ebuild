# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="a945dfdbea0f78683cea6faaecd91976abd4ad45"
CROS_WORKON_TREE="6227568acf4655e845ca0a24ae1abf8931798aaf"
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

