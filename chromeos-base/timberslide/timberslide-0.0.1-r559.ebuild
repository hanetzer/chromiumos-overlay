# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="d991372a8fe523042c477d017652e17623f2c038"
CROS_WORKON_TREE="730532f799afaf6b1343c8daa8341d95e33b7b7c"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_USE_VCSID=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="timberslide"

inherit cros-workon platform

DESCRIPTION="EC log concatenator for Chromium OS"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="chromeos-base/libbrillo"

DEPEND="${RDEPEND}"

src_install() {
	dobin "${OUT}/timberslide"

	insinto /etc/init
	doins init/*.conf
}
