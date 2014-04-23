# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

DESCRIPTION="List of packages that make up the developer OS image;
by default, we build a Chromium OS dev image"
HOMEPAGE="http://dev.chromium.org/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

# We still depend on chromeos-base/chromeos-dev for migration.
# It'll be cleaned up in a follow up commit.
RDEPEND="virtual/target-chromium-os-dev
	chromeos-base/chromeos-dev"
DEPEND="${RDEPEND}"
