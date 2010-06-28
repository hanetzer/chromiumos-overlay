# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

DESCRIPTION="Adds packages that are required for testing."
HOMEPAGE="http://src.chromium.org"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 arm"
IUSE=""

# TODO(sosa@chromium.org) - Given that we can add packages to the test image
# now, we should just install these packages to the image and remove from deps.

# Packages required for testing.
RDEPEND="${RDEPEND}
	app-admin/sudo
	app-arch/tar
	app-crypt/nss
	chromeos-base/autotest
	chromeos-base/autox
	chromeos-base/client-id-uploader
	chromeos-base/minifakedns
	x86? ( dev-java/icedtea )
	dev-lang/python
	dev-python/dbus-python
	dev-python/pygobject
	dev-python/pygtk
	dev-python/pyopenssl
	media-gfx/imagemagick[png]
	media-gfx/perceptualdiff
	net-misc/dhcp
	net-misc/iputils
	net-misc/openssh
	net-misc/rsync
	sys-apps/findutils
	sys-power/powertop
	sys-process/procps
	sys-process/psmisc
	sys-process/time
	"

# Used to disable Caps Lock and keyboard autorepeat, which can have bad
# effects on keyboard tests.
RDEPEND="${RDEPEND}
	x11-apps/xmodmap
	x11-apps/xset
	"

