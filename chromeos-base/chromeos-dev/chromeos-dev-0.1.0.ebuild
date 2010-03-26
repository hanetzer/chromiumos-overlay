# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

DESCRIPTION="Adds some developer niceties on top of Chrome OS for debugging."
HOMEPAGE="http://src.chromium.org"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 arm"
IUSE="X opengl"

# XServer
RDEPEND="${RDEPEND}
	X? ( x11-terms/aterm )
	"

# Useful utilities
RDEPEND="${RDEPEND}
	app-admin/sudo
	app-arch/tar
	x86? ( app-editors/qemacs )
	app-editors/vim
	app-shells/bash
	chromeos-base/autox
	chromeos-base/flimflam-testscripts
	chromeos-base/gmerge
	dev-lang/python
	dev-python/pyopenssl
	net-misc/iputils
	net-misc/openssh
	net-wireless/iw
	net-wireless/wireless-tools
	x86? ( sys-apps/dmidecode )
	sys-apps/findutils
	sys-apps/less
	x86? ( sys-apps/pciutils )
	x86? ( sys-apps/superiotool )
	sys-apps/usbutils
	sys-apps/which
	sys-devel/gdb
	sys-fs/fuse[-kernel_linux]
	sys-fs/sshfs-fuse
	sys-power/powertop
	sys-process/procps
	sys-process/time
        opengl? ( x11-apps/mesa-progs )
	"

# TODO: Re-add strace once we can compile it again dev-util/strace
