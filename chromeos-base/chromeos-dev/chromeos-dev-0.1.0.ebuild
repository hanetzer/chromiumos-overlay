# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

DESCRIPTION="Adds some developer niceties on top of Chrome OS for debugging"
HOMEPAGE="http://src.chromium.org"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"
IUSE="cros_embedded opengl X"

# The dependencies here are meant to capture "all the packages
# developers want to use for development, test, or debug".  This
# category is meant to include all developer use cases, including
# software test and debug, performance tuning, hardware validation,
# and debugging failures running autotest.
#
# To protect developer images from changes in other ebuilds you
# should include any package with a user constituency, regardless of
# whether that package is included in the base Chromium OS image or
# any other ebuild.
#
# Don't include packages that are indirect dependencies: only
# include a package if a file *in that package* is expected to be
# useful.

################################################################################
#
# CROS_COMMON_* : Dependencies common to all CrOS flavors (embedded, regular)
#
################################################################################

CROS_COMMON_RDEPEND="
	app-arch/tar
	app-crypt/nss
	app-editors/qemacs
	app-editors/vim
	app-shells/bash
	chromeos-base/chromeos-dev-init
	chromeos-base/gmerge
	chromeos-base/shill-test-scripts
	dev-util/strace
	net-dialup/lrzsz
	net-misc/openssh
	sys-devel/gdb
"
CROS_COMMON_DEPEND="${CROS_COMMON_RDEPEND}
"

################################################################################
#
# CROS_* : Dependencies for "regular" CrOS devices (coreutils, X etc)
#
################################################################################
CROS_X86_RDEPEND="
	app-benchmarks/i7z
	dev-util/turbostat
	sys-apps/dmidecode
	sys-apps/iotools
	sys-apps/pciutils
	x11-apps/intel-gpu-tools
"

CROS_X_RDEPEND="
	opengl? ( x11-apps/mesa-progs )
	x11-apps/mtplot
	x11-apps/xauth
	x11-apps/xdpyinfo
	x11-apps/xdriinfo
	x11-apps/xev
	x11-apps/xhost
	x11-apps/xinput
	x11-apps/xinput_calibrator
	x11-apps/xlsatoms
	x11-apps/xlsclients
	x11-apps/xmodmap
	x11-apps/xprop
	x11-apps/xrdb
	x11-apps/xset
	x11-apps/xtrace
	x11-apps/xwd
	x11-apps/xwininfo
	x11-misc/xdotool
"

CROS_RDEPEND="
	x86? ( ${CROS_X86_RDEPEND} )
	amd64? ( ${CROS_X86_RDEPEND} )
	X? ( ${CROS_X_RDEPEND} )
"

CROS_RDEPEND="${CROS_RDEPEND}
	app-admin/sudo
	app-arch/gzip
	app-benchmarks/punybench
	app-crypt/nss
	app-crypt/tpm-tools
	app-misc/evtest
	app-misc/screen
	chromeos-base/audiotest
	chromeos-base/platform2
	chromeos-base/protofiles
	dev-lang/python
	dev-python/cherrypy
	dev-python/dbus-python
	dev-util/hdctools
	dev-util/libc-bench
	media-sound/sox
	net-analyzer/netperf
	net-analyzer/tcpdump
	net-dialup/minicom
	net-misc/dhcp
	net-misc/iperf
	net-misc/iputils
	net-misc/rsync
	net-wireless/iw
	net-wireless/wireless-tools
	sys-apps/coreutils
	sys-apps/diffutils
	sys-apps/file
	sys-apps/findutils
	sys-apps/i2c-tools
	sys-apps/kbd
	sys-apps/less
	sys-apps/smartmontools
	sys-apps/usbutils
	sys-apps/which
	sys-devel/gdb
	sys-fs/fuse
	sys-fs/lvm2
	sys-fs/sshfs-fuse
	sys-power/powertop
	sys-process/ktop
	sys-process/procps
	sys-process/psmisc
	sys-process/time
	virtual/chromeos-bsp-dev
	virtual/perf
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

DEPEND="${CROS_COMMON_DEPEND}
"
