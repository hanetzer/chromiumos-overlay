# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

DESCRIPTION="List of packages that are needed inside the Chromium OS dev image"
HOMEPAGE="http://dev.chromium.org/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
# Note: Do not utilize USE=internal here.  Update virtual/target-chrome-os-dev.
IUSE="cras nvme pam opengl +power_management +profile
	+shill tpm usb vaapi video_cards_intel"

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
# CROS_* : Dependencies for CrOS devices (coreutils, etc.)
#
################################################################################
CROS_X86_RDEPEND="
	app-benchmarks/i7z
	power_management? ( dev-util/turbostat )
	sys-apps/dmidecode
	sys-apps/pciutils
	sys-boot/syslinux
	vaapi? ( media-video/libva-utils )
	video_cards_intel? ( x11-apps/intel-gpu-tools )
"

RDEPEND="
	x86? ( ${CROS_X86_RDEPEND} )
	amd64? ( ${CROS_X86_RDEPEND} )
"

RDEPEND="${RDEPEND}
	pam? ( app-admin/sudo )
	app-admin/sysstat
	app-arch/bzip2
	app-arch/gzip
	app-arch/tar
	app-arch/unzip
	app-arch/xz-utils
	app-arch/zip
	profile? (
		app-benchmarks/punybench
		chromeos-base/quipper
		dev-util/libc-bench
		net-analyzer/netperf
		dev-util/perf
	)
	app-crypt/nss
	tpm? ( app-crypt/tpm-tools )
	app-editors/nano
	app-editors/qemacs
	app-editors/vim
	app-misc/edid-decode
	app-misc/evtest
	app-misc/screen
	app-portage/portage-utils
	app-shells/bash
	cras? (
		chromeos-base/audiotest
		media-sound/sox
	)
	chromeos-base/avtest_label_detect
	chromeos-base/chromeos-dev-root
	chromeos-base/cryptohome-dev-utils
	chromeos-base/gmerge
	chromeos-base/protofiles
	shill? ( chromeos-base/shill-test-scripts )
	chromeos-base/touch_firmware_test
	net-analyzer/tcpdump
	net-dialup/minicom
	net-misc/dhcp
	net-misc/iperf:2
	net-misc/iputils
	net-misc/openssh
	net-misc/rsync
	net-wireless/iw
	net-wireless/wireless-tools
	dev-lang/python
	dev-python/protobuf-python
	dev-python/cherrypy
	dev-python/dbus-python
	dev-util/hdctools
	dev-util/mem
	dev-util/strace
	net-dialup/lrzsz
	net-misc/curl
	net-misc/wget
	sys-apps/coreboot-utils
	sys-apps/coreutils
	sys-apps/diffutils
	sys-apps/file
	sys-apps/findutils
	sys-apps/gawk
	sys-apps/i2c-tools
	sys-apps/iotools
	sys-apps/kbd
	sys-apps/less
	sys-apps/mmc-utils
	nvme? ( sys-apps/nvme-cli )
	sys-apps/smartmontools
	usb? ( sys-apps/usbutils )
	sys-apps/which
	sys-block/fio
	sys-devel/gdb
	sys-fs/fuse
	sys-fs/lvm2
	sys-fs/mtd-utils
	sys-fs/sshfs-fuse
	power_management? ( sys-power/powertop )
	sys-process/procps
	sys-process/psmisc
	sys-process/time
	virtual/autotest-capability
	virtual/chromeos-bsp-dev
"
