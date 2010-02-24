# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

DESCRIPTION="Chrome OS (meta package)"
HOMEPAGE="http://src.chromium.org"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 arm"
IUSE="X"

# XServer
RDEPEND="${RDEPEND}
	X? (
		x86? ( chromeos-base/chromeos-chrome )
		chromeos-base/chromeos-wm
		media-fonts/droid
		media-fonts/sil-abyssinica
		media-fonts/dejavu
		>=x11-base/xorg-server-1.6.3
		x11-apps/xinit
	)
	"

# Base System
# TODO(yusukes): remove x86? from the ibus-* lines once we get ibus running on ARM.
RDEPEND="${RDEPEND}
	app-admin/rsyslog
	x86? ( app-i18n/ibus-chewing )
	x86? ( app-i18n/ibus-hangul )
	x86? ( app-i18n/ibus-pinyin )
	x86? ( app-laptop/laptop-mode-tools )
	app-shells/dash
	chromeos-base/board-devices
	x86? ( chromeos-base/chromeos-acpi )
	chromeos-base/chromeos-assets
	chromeos-base/chromeos-audioconfig
	chromeos-base/chromeos-init
	chromeos-base/chromeos-installer
	x86? ( chromeos-base/chromeos-login )
	arm? ( chromeos-base/chromeos-login[slim] )
	chromeos-base/chromeos-metrics_daemon
	chromeos-base/flimflam
	chromeos-base/kernel
	x86? ( chromeos-base/libcros )
	chromeos-base/memento_softwareupdate
	chromeos-base/monitor_reconfig
	chromeos-base/pam_google
	chromeos-base/xscreensaver
	x86? ( media-gfx/ply-image )
	media-plugins/alsa-plugins
	media-sound/pulseaudio
	net-firewall/iptables
	net-misc/ntp
	x86? ( >=net-wireless/iwl5000-ucode-8.24.2.12 
               net-wireless/iwl1000-ucode
	       net-wireless/iwl6000-ucode
	)
	net-wireless/ath6k
	>=sys-apps/baselayout-2.0.0
	sys-apps/dbus
	x86? ( sys-apps/devicekit-disks )
	sys-apps/devicekit-power
	sys-apps/kbd
	sys-apps/coreutils
	sys-apps/eject
	sys-apps/grep
	sys-apps/mawk
	sys-apps/module-init-tools
	sys-apps/upstart
	sys-apps/util-linux
	sys-apps/shadow
	sys-auth/consolekit
	arm? ( sys-boot/u-boot )
	sys-fs/e2fsprogs
	sys-fs/udev
	sys-process/lsof
	sys-process/procps
	sys-process/vixie-cron
	"
