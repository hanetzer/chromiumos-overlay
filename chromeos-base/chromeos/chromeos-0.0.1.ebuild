# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

DESCRIPTION="Chrome OS (meta package)"
HOMEPAGE="http://src.chromium.org"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="bluetooth +localssh X bootchart touchui opengles"


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


# Enable ssh locally for chromium-os device.
# TODO(derat): Remove the "localssh" USE flag.  It's expanded in scope beyond
# SSH to the point where it should really be called "crosh", but building
# without it is also unsupported and likely to break a bunch of stuff.
RDEPEND="${RDEPEND}
	localssh? (
		app-admin/sudo
		app-arch/tar
		chromeos-base/crosh
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
		media-fonts/ko-nanumfonts
		media-fonts/ml-anjalioldlipi
		x11-apps/xinit
		>=x11-base/xorg-server-1.6.3
	)
	"

X86_DEPEND="
		net-wireless/iwl1000-ucode
		net-wireless/iwl3945-ucode
		net-wireless/iwl4965-ucode
		>=net-wireless/iwl5000-ucode-8.24.2.12
		net-wireless/iwl6000-ucode
		net-wireless/iwl6005-ucode
		net-wireless/iwl6030-ucode
		net-wireless/iwl6050-ucode
		sys-apps/mosys
		sys-boot/syslinux
"

RDEPEND="${RDEPEND} x86? ( ${X86_DEPEND} )"
RDEPEND="${RDEPEND} amd64? ( ${X86_DEPEND} )"

RDEPEND="${RDEPEND}
	arm? (
		chromeos-base/u-boot-scripts
	)
	"

RDEPEND="${RDEPEND}
	virtual/chromeos-bsp
	virtual/chromeos-firmware
	virtual/kernel
	"

# Specifically include the editor we want to appear in chromeos images, so that
# it is deterministic which editor is chosen by 'virtual/editor' dependencies
# (such as in the 'sudo' package).  See crosbug.com/5777.
RDEPEND="${RDEPEND}
	app-editors/vim
	"

# TODO(micahc): Remove board-devices from RDEPEND in lieu of
#               virtual/chromeos-bsp

# TODO(gauravsh): Once shill becomes the default, remove the flimflam
# dependency. crosbug.com/23531
# "shill" is the new connection manager. It is still in "experimental"
#  mode, and must be explicitly enabled (in lieu of flimflam).

# Note that o3d works with opengl on x86 and opengles on ARM, but not ARM
# opengl.

RDEPEND="${RDEPEND}
	app-admin/rsyslog
	app-arch/sharutils
	bootchart? (
		app-benchmarks/bootchart
	)
	app-crypt/trousers
	app-i18n/ibus-english-m
	app-i18n/ibus-m17n
	app-i18n/ibus-mozc
	app-i18n/ibus-mozc-chewing
	app-i18n/ibus-mozc-hangul
	app-i18n/ibus-pinyin
	app-i18n/ibus-xkb-layouts
	touchui? ( app-i18n/ibus-zinnia )
	app-laptop/laptop-mode-tools
	app-shells/dash
	chromeos-base/audioconfig
	chromeos-base/board-devices
	chromeos-base/bootstat
	chromeos-base/cashew
	chromeos-base/chromeos-assets
	chromeos-base/chromeos-assets-split
	chromeos-base/chromeos-auth-config
	chromeos-base/chromeos-base
	chromeos-base/chromeos-debugd
	chromeos-base/chromeos-imageburner
	chromeos-base/chromeos-init
	chromeos-base/chromeos-installer
	chromeos-base/chromeos-login
	chromeos-base/crash-reporter
	chromeos-base/cromo
	chromeos-base/cros-disks
	chromeos-base/cros_boot_mode
	chromeos-base/dev-install
	chromeos-base/flimflam
	chromeos-base/internal
	chromeos-base/libcros
	chromeos-base/metrics
	chromeos-base/power_manager
	chromeos-base/root-certificates
	chromeos-base/shill
	chromeos-base/speech_synthesis
	chromeos-base/update_engine
	chromeos-base/userfeedback
	chromeos-base/vboot_reference
	media-gfx/ply-image
	media-plugins/alsa-plugins
	!arm? ( media-plugins/o3d )
	arm? (
		opengles? ( media-plugins/o3d )
	)
	media-sound/alsa-utils
	media-sound/adhd
	net-firewall/iptables
	net-misc/htpdate
	net-misc/modemmanager
	net-wireless/ath3k
	net-wireless/ath6k
	net-wireless/crda
	net-wireless/marvell_sd8787
	bluetooth? (
		net-wireless/bluez
	)
	sci-geosciences/gpsd
	>=sys-apps/baselayout-2.0.0
	sys-apps/coreutils
	sys-apps/dbus
	sys-apps/eject
	sys-apps/flashrom
	sys-apps/grep
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


DEPEND="${RDEPEND}"


qemu_run() {
	# Run the emulator to execute command. It needs to be copied
	# temporarily into the sysroot because we chroot to it.
	local qemu
	case "${ARCH}" in
		amd64)
			# Note that qemu is not actually run below in this case.
			qemu="qemu-x86_64"
			;;
		arm)
			qemu="qemu-arm"
			;;
		x86)
			qemu="qemu-i386"
			;;
		*)
			die "Unable to determine QEMU from ARCH."
	esac

	# If we're running directly on the target (e.g. gmerge), we don't need to
	# chroot or use qemu.
	if [ "${ROOT:-/}" == "/" ]; then
		"$@" || die
	elif [ "${ARCH}" == "amd64" ]; then
		chroot "${ROOT}" "$@" || die
	else
		cp "/usr/bin/${qemu}" "${ROOT}/tmp" || die
		chroot "${ROOT}" "/tmp/${qemu}" "$@" || die
		rm "${ROOT}/tmp/${qemu}" || die
	fi
}

generate_font_cache() {
	mkdir -p "${ROOT}/usr/share/fontconfig" || die
	# fc-cache needs the font files to be located in their final resting place.
	qemu_run /usr/bin/fc-cache -f
}

generate_gtk_config() {
	local gtk2_confdir="/etc/gtk-2.0"

	mkdir -p "${ROOT}/${gtk2_confdir}" || die

	# Generate gtk+ config file via qemu inside chroot.
	# See http:/crosbug.com/12284
	qemu_run "/usr/bin/gtk-query-immodules-2.0" \
		> "${ROOT}/${gtk2_confdir}/gtk.immodules"
	qemu_run "/usr/bin/gdk-pixbuf-query-loaders" \
		> "${ROOT}/${gtk2_confdir}/gdk-pixbuf.loaders"
}

pkg_preinst() {
	generate_font_cache

	# This can be moved to gtk+ ebuild if necessary.
	generate_gtk_config
}
