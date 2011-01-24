# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

DESCRIPTION="Chrome OS (meta package)"
HOMEPAGE="http://src.chromium.org"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 arm"
IUSE="bluetooth +localssh modemmanager X"

DEPEND="chromeos-base/internal
	   sys-apps/baselayout"

# Enable ssh locally for chromium-os device.
# TODO(hungte) remove aterm once cros-term and factory changed to rxvt-unicode
RDEPEND="${RDEPEND}
	localssh? (
		app-admin/sudo
		app-arch/tar
		chromeos-base/workarounds
		net-misc/openssh
		x11-terms/aterm
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
	app-admin/rsyslog
	app-arch/sharutils
	app-crypt/tpm-emulator
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
	chromeos-base/chromeos-audioconfig
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
