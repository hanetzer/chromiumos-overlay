# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

DESCRIPTION="List of packages that are needed inside the Chromium OS test image;
Note: test images are a superset of dev images."
HOMEPAGE="http://dev.chromium.org/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
# Note: Do not utilize USE=internal here.  Update virtual/target-chrome-os-test.
IUSE="cros_ec cros_embedded X"

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


################################################################################
#
# CROS_COMMON_* : Dependencies common to all CrOS flavors (embedded, regular)
#
################################################################################

CROS_COMMON_RDEPEND="
	chromeos-base/chromeos-test-root
	cros_ec? ( chromeos-base/ec-utils )
	dev-util/dbus-spy
	net-misc/rsync
"

################################################################################
#
# CROS_* : Dependencies for "regular" CrOS devices (coreutils, X etc)
#
################################################################################
CROS_X86_RDEPEND="
	sys-apps/pciutils
	x11-misc/read-edid
"

CROS_X_RDEPEND="
	dev-python/pygtk
	virtual/glut
	x11-apps/setxkbmap
	x11-apps/xinput
	x11-apps/xset
	x11-misc/x11vnc
	x11-misc/xdotool
	x11-terms/rxvt-unicode
"

CROS_RDEPEND="
	x86? ( ${CROS_X86_RDEPEND} )
	amd64? ( ${CROS_X86_RDEPEND} )
	X? ( ${CROS_X_RDEPEND} )
"

CROS_RDEPEND="${CROS_RDEPEND}
	app-admin/sudo
	app-arch/gzip
	app-arch/tar
	app-benchmarks/lmbench
	app-crypt/tpm-tools
	app-misc/ckermit
	app-misc/tmux
	app-misc/utouch-evemu
	chromeos-base/autotest-client
	chromeos-base/audiotest
	chromeos-base/avtest_label_detect
	chromeos-base/chromeos-factory-regions
	chromeos-base/shill-test-scripts
	chromeos-base/minifakedns
	chromeos-base/modem-diagnostics
	chromeos-base/platform2
	chromeos-base/protofiles
	chromeos-base/recover-duts
	chromeos-base/telemetry
	chromeos-base/touchbot
	dev-lang/python
	dev-libs/opensc
	dev-libs/protobuf-python
	dev-python/btsocket
	dev-python/dbus-python
	dev-python/dpkt
	dev-python/jsonrpclib
	dev-python/netifaces
	dev-python/pygobject
	dev-python/pyserial
	dev-python/python-evdev
	dev-python/pyudev
	dev-python/pyyaml
	dev-python/selenium
	dev-python/setproctitle
	dev-python/ws4py
	dev-util/stressapptest
	games-util/joystick
	media-gfx/imagemagick[png]
	media-gfx/perceptualdiff
	media-gfx/zbar
	media-libs/opencv
	media-libs/tiff
	media-sound/sox
	net-analyzer/netperf
	net-dialup/minicom
	net-dns/dnsmasq
	net-misc/dhcp
	net-misc/iperf
	net-misc/iputils
	net-misc/openssh
	net-misc/radvd
	net-wireless/hostapd
	sci-geosciences/gpsd
	sys-apps/coreutils
	sys-apps/dtc
	sys-apps/file
	sys-apps/findutils
	sys-apps/kbd
	sys-apps/memtester
	sys-apps/shadow
	sys-devel/binutils
	sys-process/procps
	sys-process/psmisc
	sys-process/time
	x11-libs/libdrm-tests
	"

################################################################################
# CROS_E_* : Dependencies for embedded CrOS devices (busybox, no X etc)
#
################################################################################

#CROS_E_RDEPEND="${CROS_E_RDEPEND}
#"

# Build time dependencies
#CROS_E_DEPEND="${CROS_E_RDEPEND}
#"

################################################################################
# Assemble the final RDEPEND and DEPEND variables for portage
################################################################################
RDEPEND="${CROS_COMMON_RDEPEND}
	!cros_embedded? ( ${CROS_RDEPEND} )
"

# Packages that are only installed into the sysroot and are needed for running
# unit tests
DEPEND="
	chromeos-base/chromite
"
