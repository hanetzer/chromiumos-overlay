# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="241fcf47ca1685eaf30f6fc098e250c665d6c774"
CROS_WORKON_TREE="994b0f8ef2630ed865659609d23242413f8c29ea"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="thd"

inherit cros-workon platform user

DESCRIPTION="Thermal Daemon for Chromium OS"
HOMEPAGE="http://dev.chromium.org/chromium-os/packages/thd"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND="chromeos-base/libbrillo"
DEPEND="${RDEPEND}"

pkg_preinst() {
	enewuser thermal
	enewgroup thermal
}

src_install() {
	dobin "${OUT}"/thd

	dodir /etc/thd/

	insinto /etc/init
	doins init/*.conf
}
