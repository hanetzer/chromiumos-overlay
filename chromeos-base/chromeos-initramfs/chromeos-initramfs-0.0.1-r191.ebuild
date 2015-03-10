# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="f4016d69b9b5be98c6cfd660d811fd39369188bc"
CROS_WORKON_TREE="13a98baec1d312d0c8593f24e926bb382757f147"
CROS_WORKON_PROJECT="chromiumos/platform/initramfs"
CROS_WORKON_LOCALNAME="initramfs"
CROS_WORKON_OUTOFTREE_BUILD="1"

inherit cros-workon cros-board

DESCRIPTION="Create Chrome OS initramfs"
HOMEPAGE="http://www.chromium.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="frecon +interactive_recovery -mtd +power_management"

# Build Targets
IUSE+=" recovery_ramfs netboot_ramfs factory_shim_ramfs"

# Packages required for building recovery initramfs.
RECOVERY_DEPENDS="
	chromeos-base/chromeos-installer
	chromeos-base/common-assets
	chromeos-base/vboot_reference
	chromeos-base/vpd
	media-gfx/ply-image
	sys-apps/flashrom
	sys-apps/pv
	sys-fs/lvm2
	virtual/assets
	"

# Packages required for building factory installer shim initramfs.
FACTORY_SHIM_DEPENDS="
	chromeos-base/vboot_reference
	"

# Packages required for building factory netboot installer initramfs.
FACTORY_NETBOOT_DEPENDS="
	app-arch/sharutils
	app-shells/bash
	chromeos-base/chromeos-base
	chromeos-base/chromeos-factoryinstall
	chromeos-base/chromeos-installer
	chromeos-base/chromeos-installshim
	chromeos-base/ec-utils
	chromeos-base/memento_softwareupdate
	chromeos-base/vboot_reference
	chromeos-base/vpd
	dev-libs/openssl
	dev-util/shflags
	dev-util/xxd
	net-misc/htpdate
	net-misc/wget
	sys-apps/coreutils
	sys-apps/flashrom
	sys-apps/util-linux
	sys-block/parted
	sys-fs/dosfstools
	sys-fs/e2fsprogs
	sys-libs/ncurses
	sys-apps/iproute2
	"

DEPEND="recovery_ramfs? ( ${RECOVERY_DEPENDS} )
	factory_shim_ramfs? ( ${FACTORY_SHIM_DEPENDS} )
	netboot_ramfs? ( ${FACTORY_NETBOOT_DEPENDS} )
	sys-apps/busybox[-make-symlinks]
	chromeos-base/chromeos-init
	frecon? ( sys-apps/frecon )
	power_management? ( chromeos-base/power_manager ) "

RDEPEND=""

src_prepare() {
	local srcroot='/mnt/host/source'
	export BUILD_LIBRARY_DIR="${srcroot}/src/scripts/build_library"
	export INTERACTIVE_COMPLETE="$(usex interactive_recovery true false)"

	# Need the lddtree from the chromite dir.
	local chromite_bin="${srcroot}/chromite/bin"
	export PATH="${chromite_bin}:${PATH}"
}

src_compile() {
	local deps=()
	# TODO(hungte) Enable frecon when it can really run inside initramfs.
	# Currently it simply won't run and may exceed kernel size limit on some
	# boards.
	# use frecon && deps+=(/sbin/frecon)
	use mtd && deps+=(/usr/bin/cgpt.bin)
	if use netboot_ramfs; then
		use power_management && deps+=(/usr/bin/backlight_tool)
	fi

	local targets=()
	use recovery_ramfs && targets+=(recovery)
	use factory_shim_ramfs && targets+=(factory_shim)
	use netboot_ramfs && targets+=(factory_netboot)
	if [[ "${targets[*]}" = "" ]]; then
		die "No targets specified."
	fi
	einfo "Building targets: ${targets[*]}"

	emake SYSROOT="${SYSROOT}" BOARD="$(get_current_board_with_variant)" \
		OUTPUT_DIR="${WORKDIR}" EXTRA_BIN_DEPS="${deps[*]}" \
		LOCALE_LIST="${RECOVERY_LOCALES}" ${targets[*]}
}

src_install() {
	insinto /var/lib/misc
	# TODO(hungte) Change the legacy name 'initramfs.cpio.xz' to correct new
	# name (recovery_ramfs.cpio.xz).
	use recovery_ramfs &&
		newins "${WORKDIR}"/initramfs.cpio.xz recovery_ramfs.cpio.xz
	use factory_shim_ramfs && doins "${WORKDIR}"/factory_shim_ramfs.cpio.xz
	use netboot_ramfs && doins "${WORKDIR}"/netboot_ramfs.cpio.xz
}
