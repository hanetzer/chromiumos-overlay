# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="1e98191674f4aff16d74d5b8de6d7b14246d1b66"
CROS_WORKON_TREE="c77a325a5d7e08bf0bdf1c3c55a9182b2d3eecb9"
CROS_WORKON_PROJECT="chromiumos/platform/init"
CROS_WORKON_LOCALNAME="init"

inherit cros-workon

DESCRIPTION="Additional upstart jobs that will be installed on dev images"
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"

src_install() {
	insinto /etc/init
	doins dev-init/*.conf
}
