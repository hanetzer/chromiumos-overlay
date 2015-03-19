# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT="f5b7e4c4f7a185ec2c365cb77fecec6626d84069"
CROS_WORKON_TREE="e2f3ff61cfce9b7987ca0c8dc885ab9b573fc7ad"
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