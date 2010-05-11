# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

DESCRIPTION="Chrome OS (meta package)"
HOMEPAGE="http://src.chromium.org"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 arm"
IUSE="X +localssh"

DEPEND="sys-apps/baselayout
	chromeos-base/internal"

# Enable ssh locally for chromium-os device.
RDEPEND="${RDEPEND}
	localssh? (
		app-admin/sudo
		net-misc/openssh
		X? ( x11-terms/aterm )
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
		media-fonts/dejavu
		media-fonts/droid
		media-fonts/ja-ipafonts
		media-fonts/sil-abyssinica
		>=x11-base/xorg-server-1.6.3
		x11-apps/xinit
	)
	"

# Base System
# TODO(yusukes): remove x86? from the ibus-* lines once we get ibus running on ARM.
RDEPEND="${RDEPEND}
	app-admin/rsyslog
	app-crypt/tpm-emulator
        app-crypt/trousers
	x86? ( app-i18n/ibus-chewing )
	app-i18n/ibus-hangul
	x86? ( app-i18n/ibus-m17n )
	app-i18n/ibus-pinyin
	app-i18n/ibus-xkb-layouts
	x86? ( app-laptop/laptop-mode-tools )
	app-shells/dash
	chromeos-base/board-devices
	x86? ( chromeos-base/chromeos-acpi )
	chromeos-base/chromeos-assets
	chromeos-base/chromeos-audioconfig
	chromeos-base/chromeos-init
	chromeos-base/chromeos-installer
	chromeos-base/chromeos-login
	chromeos-base/crash-reporter
	chromeos-base/entd
	chromeos-base/flimflam
	chromeos-base/internal
	chromeos-base/kernel
	chromeos-base/libcros
	chromeos-base/memento_softwareupdate
	chromeos-base/metrics
	chromeos-base/monitor_reconfig
	chromeos-base/pam_google
	chromeos-base/power_manager
	x86? ( chromeos-base/speech_synthesis )
	x86? ( chromeos-base/update_engine )
	chromeos-base/xscreensaver
	x86? ( dev-util/perf )
	x86? ( media-gfx/ply-image )
	media-plugins/alsa-plugins
	x86? ( media-plugins/o3d )
	media-sound/alsa-utils
	media-sound/pulseaudio
	net-firewall/iptables
	net-misc/ntp
	x86? ( >=net-wireless/iwl5000-ucode-8.24.2.12
               net-wireless/iwl1000-ucode
	       net-wireless/iwl6000-ucode
	)
	net-wireless/ath6k
	net-wireless/bluez
	net-wireless/marvell_sd8787
	sci-geosciences/gpsd
	>=sys-apps/baselayout-2.0.0
	sys-apps/coreutils
	sys-apps/dbus
	x86? ( sys-apps/devicekit-disks )
	sys-apps/devicekit-power
	sys-apps/eject
	x86? ( sys-apps/flashrom )
	sys-apps/grep
	sys-apps/kbd
	sys-apps/mawk
	sys-apps/module-init-tools
        sys-apps/rootdev
	sys-apps/sed
	sys-apps/shadow
	sys-apps/upstart
	sys-apps/util-linux
	sys-auth/consolekit
	arm? ( sys-boot/u-boot )
        sys-block/gpt
	sys-fs/e2fsprogs
	sys-fs/udev
	sys-libs/timezone-data
	sys-process/lsof
	sys-process/procps
	sys-process/vixie-cron
	"
