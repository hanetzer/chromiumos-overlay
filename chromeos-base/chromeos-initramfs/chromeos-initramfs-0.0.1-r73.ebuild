# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="518d408e50551620da41530d992c9cf41b22f75a"
CROS_WORKON_PROJECT="chromiumos/platform/initramfs"

inherit cros-workon

DESCRIPTION="Create Chrome OS initramfs"
HOMEPAGE="http://www.chromium.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""
DEPEND="chromeos-base/chromeos-assets
	chromeos-base/vboot_reference
	chromeos-base/vpd
	media-gfx/ply-image
	sys-apps/busybox
	sys-apps/flashrom
	sys-apps/pv
	sys-fs/lvm2"
RDEPEND=""

CROS_WORKON_LOCALNAME="../platform/initramfs"

INITRAMFS_TMP_S=${WORKDIR}/initramfs_tmp
INITRAMFS_FILE="initramfs.cpio.gz"

# dobin for initramfs
idobin() {
	local src
	for src in "$@"; do
		"${FILESDIR}/copy_elf" "${ROOT}" "${INITRAMFS_TMP_S}" "${src}" ||
			die "Cannot install: $src"
		elog "Copied: $src"
	done
}

build_initramfs_file() {
	local dir

	local subdirs="
		bin
		dev
		etc
		etc/screens
		lib
		log
		newroot
		proc
		stateful
		sys
		tmp
		usb
	"
	for dir in $subdirs; do
		mkdir -p "${INITRAMFS_TMP_S}/$dir" || die
	done

	# On amd64, shared libraries must live in /lib64.  More generally,
	# $(get_libdir) tells us the directory name we need for the target
	# platform's libraries.  The 'copy_elf' script installs in /lib; to
	# keep that script simple we just create a symlink to /lib, if
	# necessary.
	local libdir=$(get_libdir)
	if [ "${libdir}" != "lib" ]; then
		ln -s lib "${INITRAMFS_TMP_S}/${libdir}"
	fi

	# Copy source files not merged from our dependencies.
	cp init "${INITRAMFS_TMP_S}/init" || die
	chmod +x "${INITRAMFS_TMP_S}/init"
	cp *.sh "${INITRAMFS_TMP_S}/lib" || die
	local assets="${ROOT}"/usr/share/chromeos-assets
	cp "${assets}"/images/boot_message.png "${INITRAMFS_TMP_S}"/etc/screens
	cp -r "${assets}"/images/spinner "${INITRAMFS_TMP_S}"/etc/screens
	${S}/make_images "${S}/localized_text" \
					 "${INITRAMFS_TMP_S}/etc/screens" || die

	# For busybox and sh
	idobin /bin/busybox
	ln -s busybox "${INITRAMFS_TMP_S}/bin/sh"

	# For verified rootfs
	idobin /sbin/dmsetup

	# For message screen display and progress bars
	idobin /usr/bin/ply-image
	idobin /usr/bin/pv
	idobin /usr/sbin/vpd

	# /usr/sbin/vpd invokes 'flashrom' via system()
	idobin /usr/sbin/flashrom

	# For recovery behavior
	idobin /usr/bin/cgpt
	idobin /usr/bin/crossystem
	idobin /usr/bin/dump_kernel_config
	idobin /usr/bin/tpmc
	idobin /usr/bin/vbutil_kernel

	# The kernel emake expects the file in cpio format.
	( cd "${INITRAMFS_TMP_S}"
	  find . | cpio -o -H newc |
		gzip -9 > "${WORKDIR}/${INITRAMFS_FILE}" ) ||
		die "cannot package initramfs"
}

src_compile() {
	einfo "Creating ${INITRAMFS_FILE}"
	build_initramfs_file
	INITRAMFS_FILE_SIZE=$(stat --printf="%s" "${WORKDIR}/${INITRAMFS_FILE}")
	einfo "${INITRAMFS_FILE}: ${INITRAMFS_FILE_SIZE} bytes"
}

src_install() {
	insinto /var/lib/misc
	doins "${WORKDIR}/${INITRAMFS_FILE}"
}
