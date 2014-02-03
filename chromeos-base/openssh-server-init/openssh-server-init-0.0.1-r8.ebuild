# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="17b3a32bbfab60e7a999ba687d7c6eaa554e1fc8"
CROS_WORKON_TREE="2c3a4de551bd6e1c03847adb24ced29b6b98e44e"
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
