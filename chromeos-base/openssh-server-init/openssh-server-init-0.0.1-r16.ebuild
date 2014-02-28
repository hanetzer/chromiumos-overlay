# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="b8f114ea666d9726ef671b4b1096d311056a4c50"
CROS_WORKON_TREE="bb0f89031b5a36fbc16ba0ecd11639ef7d5f248b"
CROS_WORKON_PROJECT="chromiumos/platform/init"
CROS_WORKON_LOCALNAME="init"

inherit cros-workon

DESCRIPTION="Install the upstart job that launches the openssh-server."
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND="!chromeos-base/chromeos-dev-init"

src_install() {
	insinto /etc/init
	doins openssh-server-init/*.conf
}
