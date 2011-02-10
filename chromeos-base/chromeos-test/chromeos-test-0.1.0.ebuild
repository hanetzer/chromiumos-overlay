# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

DESCRIPTION="Adds packages that are required for testing."
HOMEPAGE="http://src.chromium.org"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 arm"
IUSE=""

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
# TODO(jrbarnette):  It's not known definitively that the list
# below contains no unneeded dependencies.  More work is needed to
# determine for sure that every package listed is actually used.
RDEPEND="${RDEPEND}
	app-admin/sudo
	app-arch/gzip
	app-arch/tar
	app-crypt/tpm-tools
	chromeos-base/autox
	chromeos-base/flimflam-test
	chromeos-base/minifakedns
	x86? ( chromeos-base/modem-diagnostics )
	x86? ( dev-java/icedtea )
	dev-lang/python
	dev-python/dbus-python
	dev-python/pygobject
	dev-python/pygtk
	media-gfx/imagemagick[png]
	media-gfx/perceptualdiff
	net-analyzer/netperf
	net-misc/dhcp
	net-misc/iperf
	net-misc/iputils
	net-misc/openssh
	net-misc/rsync
	sys-apps/coreutils
	sys-apps/findutils
	x86? ( sys-apps/pciutils )
	x86? ( sys-apps/superiotool )
	sys-apps/shadow
	sys-process/procps
	sys-process/psmisc
	sys-process/time
	x11-apps/setxkbmap
	x11-apps/xauth
	x11-apps/xset
	x86? ( x11-misc/read-edid )
	x11-terms/aterm
	"
