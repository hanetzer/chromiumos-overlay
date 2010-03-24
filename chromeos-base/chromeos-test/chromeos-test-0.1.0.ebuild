# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

DESCRIPTION="Adds packages that are required for testing."
HOMEPAGE="http://src.chromium.org"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 arm"
IUSE="-autotest"

# TODO(sosa@chromium.org) - Given that we can add packages to the test image
# now, we should just install these packages to the image and remove from deps.

# Packages for getting autotest onto image.
RDEPEND="${RDEPEND}
	autotest? ( 
		chromeos-base/autotest[autox, buildcheck, xset]
	)
	"

# Packages required for testing."
RDEPEND="${RDEPEND}
	app-admin/sudo
	app-arch/tar
	chromeos-base/flimflam-testscripts
	dev-lang/python
	net-misc/openssh
	net-misc/rsync
	sys-power/powertop
	sys-process/procps
	sys-process/time
	"
