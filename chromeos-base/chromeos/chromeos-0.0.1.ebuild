# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

DESCRIPTION="Chrome OS (meta package)"
HOMEPAGE="http://src.chromium.org"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 arm"
IUSE="bluetooth +localssh modemmanager X"


################################################################################
#
# READ THIS BEFORE ADDING PACKAGES TO THIS EBUILD!
#
################################################################################
#
# Every chromeos dependency (along with its dependencies) is included in the
# release image -- more packages contribute to longer build times, a larger
# image, slower and bigger auto-updates, increased security risks, etc. Consider
# the following before adding a new package:
#
# 1. Does the package really need to be part of the release image?
#
# Some packages can be included only in the developer or test images, i.e., the
# chromeos-dev or chromeos-test ebuilds. If the package will eventually be used
# in the release but it's still under development, consider adding it to
# chromeos-dev initially until it's ready for production.
#
# 2. Why is the package a direct dependency of the chromeos ebuild?
#
# It makes sense for some packages to be included as a direct dependency of the
# chromeos ebuild but for most it doesn't. The package should be added as a
# direct dependency of the ebuilds for all packages that actually use it -- in
# time, this ensures correct builds and allows easier cleanup of obsolete
# packages. For example, if a utility will be invoked by the session manager,
# its package should be added as a dependency in the chromeos-login ebuild. Or
# if the package adds a daemon that will be started through an upstart job, it
# should be added as a dependency in the chromeos-init ebuild. If the package
# really needs to be a direct dependency of the chromeos ebuild, consider adding
# a comment why the package is needed and how it's used.
#
# 3. Are all default package features and dependent packages needed?
#
# The release image should include only packages and features that are needed in
# the production system. Often packages pull in features and additional packages
# that are never used. Review these and consider pruning them (e.g., through USE
# flags).
#
# 4. What is the impact on the image size?
#
# Before adding a package, evaluate the impact on the image size. If the package
# and its dependencies increase the image size significantly, consider
# alternative packages or approaches.
#
# 5. Is the package needed on all targets?
#
# If the package is needed only on some target boards, consider making it
# conditional through USE flags in the board overlays.
#
################################################################################


DEPEND="chromeos-base/internal
	   sys-apps/baselayout"

# Enable ssh locally for chromium-os device.
RDEPEND="${RDEPEND}
	localssh? (
		app-admin/sudo
		app-arch/tar
		chromeos-base/workarounds
		net-misc/openssh
		x11-terms/rxvt-unicode
	)
	"

# XServer
RDEPEND="${RDEPEND}
	X? (
		chromeos-base/chromeos-chrome
		chromeos-base/chromeos-wm
		chromeos-base/flash-war
		chromeos-base/internal
		chromeos-base/xorg-conf
		media-fonts/croscorefonts
		media-fonts/dejavu
		media-fonts/droidfonts-cros
		media-fonts/ja-ipafonts
		media-fonts/lohitfonts-cros
		media-fonts/sil-abyssinica
		x11-apps/xinit
		>=x11-base/xorg-server-1.6.3
		x86? (
			x11-misc/xcalib
		)
	)
	"

RDEPEND="${RDEPEND}
	x86? (
		chromeos-base/chromeos-acpi
		chromeos-base/chrontel
		chromeos-base/firmware-utils
		chromeos-base/saft
		net-wireless/iwl1000-ucode
		>=net-wireless/iwl5000-ucode-8.24.2.12
		net-wireless/iwl6000-ucode
		sys-apps/flashrom
		sys-apps/mosys
		sys-boot/syslinux
	)
	"

RDEPEND="${RDEPEND}
	arm? (
		virtual/u-boot
	)
	"

RDEPEND="${RDEPEND}
	virtual/chromeos-bsp
        "

#TODO(micahc): Remove board-devices from RDEPEND in lieu of virtual/chromeos-bsp
RDEPEND="${RDEPEND}
	app-admin/rsyslog
	app-arch/sharutils
	app-crypt/trousers
	app-i18n/ibus-chewing
	app-i18n/ibus-hangul
	app-i18n/ibus-m17n
	app-i18n/ibus-mozc
	app-i18n/ibus-pinyin
	app-i18n/ibus-xkb-layouts
	app-laptop/laptop-mode-tools
	app-shells/dash
	chromeos-base/board-devices
	chromeos-base/bootstat
	chromeos-base/cashew
	chromeos-base/chromeos-assets
	chromeos-base/chromeos-assets-split
	chromeos-base/chromeos-firmware
	chromeos-base/chromeos-imageburner
	chromeos-base/chromeos-init
	chromeos-base/chromeos-installer
	chromeos-base/chromeos-login
	chromeos-base/crash-reporter
	chromeos-base/cromo
	chromeos-base/cros_boot_mode
	chromeos-base/entd
	chromeos-base/flimflam
	chromeos-base/internal
	virtual/kernel
	chromeos-base/libcros
	chromeos-base/metrics
	chromeos-base/monitor_reconfig
	chromeos-base/power_manager
	chromeos-base/speech_synthesis
	chromeos-base/update_engine
	chromeos-base/userfeedback
	chromeos-base/vboot_reference
	media-gfx/ply-image
	media-plugins/alsa-plugins
	media-plugins/o3d
	media-sound/alsa-utils
	media-sound/pulseaudio
	net-firewall/iptables
	net-misc/htpdate
	modemmanager? (
		net-misc/modemmanager
	)
	net-wireless/ath3k
	net-wireless/ath6k
	net-wireless/marvell_sd8787
	bluetooth? (
		net-wireless/bluez
	)
	sci-geosciences/gpsd
	>=sys-apps/baselayout-2.0.0
	sys-apps/coreutils
	sys-apps/dbus
	sys-apps/devicekit-disks
	sys-apps/devicekit-power
	sys-apps/eject
	sys-apps/grep
	sys-apps/kbd
	sys-apps/mawk
	sys-apps/module-init-tools
	sys-apps/net-tools
	sys-apps/pv
	sys-apps/rootdev
	sys-apps/sed
	sys-apps/shadow
	sys-apps/upstart
	sys-apps/ureadahead
	sys-apps/util-linux
	sys-auth/consolekit
	sys-auth/pam_pwdfile
	sys-fs/e2fsprogs
	sys-fs/udev
	sys-libs/timezone-data
	sys-process/lsof
	sys-process/procps
	sys-process/vixie-cron
	"

# TODO(dianders):
# In gentoo, the 'which' command is part of 'system'.  That means that packages
# assume that it's there and don't list it as an explicit dependency.  At the
# moment, we don't emerge 'system', but we really should at least emerge the
# embedded profile system.  Until then, we'll list it as a dependency here.
#
# Note that even gentoo's 'embedded' profile effectively has 'which' in its
# implicit dependencies, since it depepends on busybox and the default busybox
# config from gentoo provides which.
#
# See http://crosbug.com/8144
RDEPEND="${RDEPEND}
	sys-apps/which
	"
