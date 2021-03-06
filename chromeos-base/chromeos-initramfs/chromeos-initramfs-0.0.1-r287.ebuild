# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="e7d2404dd2e3fc6e21b53d40765ed6fbfb8f8c2c"
CROS_WORKON_TREE="3d7a6a8a81b129d5f8bedbe7330b2618ac64dfed"
CROS_WORKON_PROJECT="chromiumos/platform/initramfs"
CROS_WORKON_LOCALNAME="initramfs"
CROS_WORKON_OUTOFTREE_BUILD="1"

inherit cros-workon cros-board

DESCRIPTION="Create Chrome OS initramfs"
HOMEPAGE="http://www.chromium.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="device_tree frecon +interactive_recovery -mtd +power_management"

# Build Targets
TARGETS_IUSE="
	factory_netboot_ramfs
	factory_shim_ramfs
	recovery_ramfs
"
IUSE+=" ${TARGETS_IUSE}"
REQUIRED_USE="|| ( ${TARGETS_IUSE} )"

# Packages required for building recovery initramfs.
RECOVERY_DEPENDS="
	chromeos-base/chromeos-installer
	chromeos-base/common-assets
	chromeos-base/vboot_reference
	chromeos-base/vpd
	sys-apps/flashrom
	sys-apps/pv
	virtual/assets
	virtual/chromeos-regions
	"

# Packages required for building factory installer shim initramfs.
FACTORY_SHIM_DEPENDS="
	chromeos-base/factory_installer
	chromeos-base/vboot_reference
	"

# Packages required for building factory netboot installer initramfs.
FACTORY_NETBOOT_DEPENDS="
	app-arch/lbzip2
	app-arch/pigz
	app-arch/sharutils
	app-misc/jq
	app-shells/bash
	chromeos-base/chromeos-base
	chromeos-base/chromeos-installer
	chromeos-base/chromeos-installshim
	chromeos-base/ec-utils
	chromeos-base/factory_installer
	chromeos-base/vboot_reference
	chromeos-base/vpd
	dev-libs/openssl
	dev-util/shflags
	dev-util/xxd
	net-misc/curl
	net-misc/htpdate
	net-misc/wget
	sys-apps/coreutils
	sys-apps/flashrom
	sys-apps/iproute2
	sys-apps/mosys
	sys-apps/util-linux
	sys-block/parted
	sys-fs/dosfstools
	sys-fs/e2fsprogs
	sys-libs/ncurses
	virtual/udev
	"

DEPEND="
	factory_netboot_ramfs? ( ${FACTORY_NETBOOT_DEPENDS} )
	factory_shim_ramfs? ( ${FACTORY_SHIM_DEPENDS} )
	recovery_ramfs? ( ${RECOVERY_DEPENDS} )
	sys-apps/busybox[-make-symlinks]
	sys-fs/lvm2
	virtual/chromeos-bsp-initramfs
	chromeos-base/chromeos-init
	frecon? ( sys-apps/frecon-lite virtual/udev )
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
	use frecon && deps+=( /sbin/frecon-lite /sbin/udevd /bin/udevadm )
	use mtd && deps+=(/usr/bin/cgpt.bin)
	if use factory_netboot_ramfs; then
		use power_management && deps+=(/usr/bin/backlight_tool)
	fi

	local targets=()
	for target in ${TARGETS_IUSE}; do
		use ${target} && targets+=(${target%_ramfs})
	done
	einfo "Building targets: ${targets[*]}"

	emake SYSROOT="${SYSROOT}" BOARD="$(get_current_board_with_variant)" \
		INCLUDE_FIT_PICKER="$(usex device_tree 1 0)" \
		OUTPUT_DIR="${WORKDIR}" EXTRA_BIN_DEPS="${deps[*]}" \
		LOCALE_LIST="${RECOVERY_LOCALES}" ${targets[*]}
}

src_install() {
	insinto /var/lib/initramfs
	for target in ${TARGETS_IUSE}; do
		use ${target} &&
			doins "${WORKDIR}"/${target}.cpio.xz
	done
}
