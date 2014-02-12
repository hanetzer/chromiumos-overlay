# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="d4ad120743fc81906d9da1321d00a9915f62e2b4"
CROS_WORKON_TREE="31aac4e85c2f566381490e2903e15ac8f0c918bc"
CROS_WORKON_PROJECT="chromiumos/platform/init"
CROS_WORKON_LOCALNAME="init"

inherit cros-workon

DESCRIPTION="Additional upstart jobs that will be installed on test images"
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD"
SLOT="0"
KEYWORDS="*"

# TODO(victoryang): Remove factorytest-init package entirely after Feb 2014.
#                   crosbug.com/p/24798.
DEPEND=">=chromeos-base/factorytest-init-0.0.1-r32"

src_install() {
	insinto /etc/init
	doins test-init/*.conf
}

