# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

DESCRIPTION="Adds packages that are required for testing."
HOMEPAGE="http://src.chromium.org"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="+bluetooth"

# Packages required to support autotest images.  Dependencies here
# are for packages that must be present on a local device and that
# are not downloaded by the autotest server.  This includes both
# packages relied on by the server, as well as packages relied on by
# specific tests.
#
# This package is not meant to capture tools useful for test debug;
# use the chromeos-dev package for that purpose.
#
# Note that some packages used by autotest are actually built by the
# autotest package and downloaded by the server, regardless of
# whether the package is present on the target device; those
# packages aren't listed here.
#
# Developers should be aware that packages installed by this ebuild
# are rooted in /usr/local.  This means that libraries are installed
# in /usr/local/lib, executables in /usr/local/bin, etc.
#
# TODO(jrbarnette):  It's not known definitively that the list
# below contains no unneeded dependencies.  More work is needed to
# determine for sure that every package listed is actually used.
RDEPEND="${RDEPEND}
	app-admin/sudo
	app-arch/gzip
	app-arch/tar
	app-crypt/tpm-tools
	chromeos-base/autox
	chromeos-base/chromeos-factorytools
	chromeos-base/flimflam-test
	chromeos-base/minifakedns
	chromeos-base/modem-diagnostics
        chromeos-base/saft
	dev-lang/python
	dev-python/dbus-python
	dev-python/pygobject
	dev-python/pygtk
	dev-python/pyudev
	dev-python/pyyaml
	media-gfx/imagemagick[png]
	media-gfx/perceptualdiff
	media-libs/tiff
	net-analyzer/netperf
	net-dialup/minicom
	x86? ( net-dns/dnsmasq )
	net-misc/dhcp
	net-misc/iperf
	net-misc/iputils
	net-misc/openssh
	net-misc/rsync
	bluetooth? ( net-wireless/bluez )
	x86? ( net-wireless/hostapd )
	sys-apps/coreutils
	sys-apps/file
	sys-apps/findutils
	sys-apps/kbd
	x86? ( sys-apps/pciutils )
	x86? ( sys-apps/superiotool )
	sys-apps/shadow
	sys-process/procps
	sys-process/psmisc
	sys-process/time
	virtual/glut
	x11-apps/setxkbmap
	x11-apps/xauth
	x11-apps/xinput
	x11-apps/xset
	x86? ( x11-misc/read-edid )
	x11-terms/rxvt-unicode
	app-misc/utouch-evemu
	chromeos-base/ixchariot
	"
