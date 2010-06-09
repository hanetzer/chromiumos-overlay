# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

DESCRIPTION="Chrome OS (meta package)"
HOMEPAGE="http://src.chromium.org"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 arm"
IUSE="X +localssh"

DEPEND="chromeos-base/internal
       sys-apps/baselayout"

# Enable ssh locally for chromium-os device.
RDEPEND="${RDEPEND}
	localssh? (
		app-admin/sudo
		app-arch/tar
		net-misc/openssh
		x11-terms/aterm
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
		x11-apps/xinit
		>=x11-base/xorg-server-1.6.3
	)
	"

RDEPEND="${RDEPEND}
	x86? (
		app-i18n/ibus-chewing
		app-laptop/laptop-mode-tools
		chromeos-base/chromeos-acpi
		chromeos-base/firmware-utils
		chromeos-base/speech_synthesis
		media-plugins/o3d
		net-wireless/iwl1000-ucode
		>=net-wireless/iwl5000-ucode-8.24.2.12
		net-wireless/iwl6000-ucode
		sys-apps/flashrom
	)
	"

RDEPEND="${RDEPEND}
	arm? (
		sys-boot/u-boot
	)
	"

RDEPEND="${RDEPEND}
	app-admin/rsyslog
	app-arch/sharutils
	app-crypt/tpm-emulator
        app-crypt/trousers
	app-i18n/ibus-hangul
	app-i18n/ibus-m17n
	app-i18n/ibus-mozc
	app-i18n/ibus-pinyin
	app-i18n/ibus-xkb-layouts
	app-shells/dash
	chromeos-base/board-devices
	chromeos-base/chromeos-assets
	chromeos-base/chromeos-audioconfig
	chromeos-base/chromeos-init
	chromeos-base/chromeos-installer
	chromeos-base/chromeos-login
	chromeos-base/crash-reporter
	chromeos-base/cromo
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
	chromeos-base/update_engine
	chromeos-base/userfeedback
	chromeos-base/xscreensaver
	media-gfx/ply-image
	media-plugins/alsa-plugins
	media-sound/alsa-utils
	media-sound/pulseaudio
	net-firewall/iptables
	net-misc/htpdate
	net-wireless/ath3k
	net-wireless/ath6k
	net-wireless/bluez
	net-wireless/marvell_sd8787
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
        sys-apps/rootdev
	sys-apps/sed
	sys-apps/shadow
	sys-apps/upstart
	sys-apps/util-linux
	sys-auth/consolekit
        sys-block/gpt
	sys-fs/e2fsprogs
	sys-fs/udev
	sys-libs/timezone-data
	sys-process/lsof
	sys-process/procps
	sys-process/vixie-cron
	"
