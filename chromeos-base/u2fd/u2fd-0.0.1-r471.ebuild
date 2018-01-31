# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="f130ef83f658cf003218c7840c907ed5ea2e9726"
CROS_WORKON_TREE="7a45134e6c14b33316dc33c81b6e631c6d612b46"
CROS_WORKON_USE_VCSID="1"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_INCREMENTAL_BUILD=1

PLATFORM_SUBDIR="u2fd"

inherit cros-workon platform user

DESCRIPTION="U2FHID Emulation Daemon"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/u2fhid"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	chromeos-base/libbrillo
	chromeos-base/power_manager-client
	chromeos-base/trunks
	"

DEPEND="
	${RDEPEND}
	chromeos-base/system_api
	"

pkg_preinst() {
	enewuser u2f
}

src_install() {
	dobin "${OUT}"/u2fd

	insinto /etc/init
	doins init/*.conf
}
