# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

DESCRIPTION="Adds some developer niceties on top of Chrome OS for debugging."
HOMEPAGE="http://src.chromium.org"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 arm"
IUSE="X opengl"

# X11 apps
RDEPEND="${RDEPEND}
	x11-apps/setxkbmap
	x11-apps/xauth
	x11-apps/xdpyinfo
	x11-apps/xdriinfo
	x11-apps/xev
	x11-apps/xhost
	x11-apps/xlsatoms
	x11-apps/xlsclients
	x11-apps/xmodmap
	x11-apps/xprop
	x11-apps/xrdb
	x11-apps/xset
	x11-apps/xwininfo
	x11-terms/aterm
	"

# Useful utilities
# TODO(sosa): Remove packages from dev build once we switch to using
# the test build for the test image:
# - python packages: (dbus-python, pygobject, pygtk...)
# - media-gfx/imagemagick
RDEPEND="${RDEPEND}
	app-admin/sudo
	app-arch/tar
	app-crypt/nss
	x86? ( app-editors/qemacs )
	app-editors/vim
	app-shells/bash
	chromeos-base/autox
	chromeos-base/client-id-uploader
	chromeos-base/flimflam-testscripts
	chromeos-base/gmerge
	chromeos-base/minifakedns
	dev-lang/python
	dev-python/dbus-python
	dev-python/pygobject
	dev-python/pygtk
	dev-python/pyopenssl
	x86? ( dev-util/perf )
	dev-util/strace
	media-gfx/imagemagick[png]
	media-gfx/perceptualdiff
	net-misc/iputils
	net-misc/openssh
	net-wireless/iw
	net-wireless/wireless-tools
	x86? ( sys-apps/dmidecode )
	sys-apps/findutils
	sys-apps/less
	x86? ( sys-apps/pciutils )
	x86? ( sys-apps/iotools )
	sys-apps/usbutils
	sys-apps/which
	sys-devel/gdb
	sys-fs/fuse[-kernel_linux]
	sys-fs/sshfs-fuse
	sys-power/powertop
	sys-process/procps
	sys-process/time
	opengl? ( x11-apps/mesa-progs )
	x86? ( x11-apps/intel-gpu-tools )
	x86? ( x11-misc/read-edid )
	x86? ( sys-apps/i2c-tools )
	"

# TODO: Re-add strace once we can compile it again dev-util/strace
