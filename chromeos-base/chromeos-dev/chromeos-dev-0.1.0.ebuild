# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

DESCRIPTION="Adds some developer niceties on top of Chrome OS for debugging."
HOMEPAGE="http://src.chromium.org"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 arm"
IUSE="X"

# XServer
RDEPEND="${RDEPEND}
	X? (
		x11-apps/setxkbmap
		x11-terms/aterm 
	)
	"

# Useful utilities
RDEPEND="${RDEPEND}
	app-admin/sudo
	app-arch/tar
	app-editors/vim
	app-shells/bash
	chromeos-base/flimflam-testscripts
	chromeos-base/gmerge
	dev-lang/python
	dev-util/strace
	net-misc/iputils
	net-misc/openssh
	net-wireless/iw
	net-wireless/wireless-tools
	sys-apps/findutils
	sys-apps/less
	x86? ( sys-apps/pciutils )
	sys-apps/usbutils
	sys-apps/which
	sys-devel/gdb
	sys-fs/fuse[-kernel_linux]
	sys-fs/sshfs-fuse
	sys-power/powertop
	sys-process/procps
	sys-process/time
	"

# TODO: Add qemacs back in when ready:	x86? ( app-editors/qemacs )
