# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

DESCRIPTION="Adds some developer niceties on top of Chrome OS for debugging."
HOMEPAGE="http://src.chromium.org"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 arm"
IUSE="X"

RDEPEND="chromeos-base/chromeos"

# XServer
RDEPEND="${RDEPEND}
	X? ( x11-terms/aterm )
	"

# Useful utilities
RDEPEND="${RDEPEND}
	app-admin/sudo
	app-editors/vim
	app-shells/bash
	=dev-lang/python-2.4.6
	dev-util/strace
	net-misc/iputils
	net-misc/openssh
	net-wireless/iw
	net-wireless/wireless-tools
	sys-apps/findutils
	sys-apps/less
	sys-apps/which
	sys-devel/gdb
	sys-fs/fuse[-kernel_linux]	
	sys-fs/sshfs-fuse
	sys-process/procps
	"

# TODO: Add qemacs back in when ready:	x86? ( app-editors/qemacs )

# meta package which contains target build dependencies. Doesn't get
# built by this ebuild because we use --root-deps=rdeps but
# including it as an FYI.
DEPEND="chromeos-base/hard-target-depends"
