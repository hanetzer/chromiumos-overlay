# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT="384bc55ddfe9bfa3666b0bda26e9adf47569c336"
CROS_WORKON_TREE="3da093d90e4e4c652ab4b33a8c64dfc55100df64"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="servicemanager"

inherit cros-workon platform

DESCRIPTION="System service for managing binder services"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

src_install() {
	dolib.so "${OUT}/lib/libsimplebinder.so"
	dobin "${OUT}/servicemanager"
	dobin "${OUT}/service"

	insinto /usr/include/chromeos
	doins simplebinder.h

	# Install Upstart configuration.
	insinto /etc/init
	doins servicemanager.conf
}