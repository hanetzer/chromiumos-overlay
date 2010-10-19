# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

DESCRIPTION="Adds packages that are required for testing."
HOMEPAGE="http://src.chromium.org"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 arm"
IUSE=""

# Packages required for testing.
RDEPEND="${RDEPEND}
	app-admin/sudo
	app-arch/tar
	app-crypt/nss
	app-crypt/tpm-tools
	chromeos-base/autox
	chromeos-base/flimflam-test
	chromeos-base/minifakedns
	x86? ( chromeos-base/tpm )
	x86? ( chromeos-base/usb-server )
	x86? ( dev-java/icedtea )
	dev-lang/python
	dev-python/dbus-python
	dev-python/pygobject
	dev-python/pygtk
	dev-python/pyopenssl
	media-gfx/imagemagick[png]
	media-gfx/perceptualdiff
	net-analyzer/netperf
	net-misc/dhcp
	net-misc/iperf
	net-misc/iputils
	net-misc/openssh
	net-misc/rsync
	sys-apps/findutils
	x86? ( sys-apps/superiotool )
	sys-power/powertop
	sys-process/procps
	sys-process/psmisc
	sys-process/time
	x86? ( x11-misc/read-edid )
	"

# Used to disable Caps Lock and keyboard autorepeat, which can have bad
# effects on keyboard tests.
RDEPEND="${RDEPEND}
	x11-apps/xmodmap
	x11-apps/xset
	"

