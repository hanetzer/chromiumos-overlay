# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="75753961d55461e080178cb3d13f5bd067cf1c20"
CROS_WORKON_TREE="c8ef2a80e73dd624c43a0fa8ba2997297f1a0177"
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
