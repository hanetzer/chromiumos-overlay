# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# WARNING: cros_workon cannot detect changes to files/, please ensure
# that you manually bump or make some change to the 9999 ebuild until
# this is fixed.

EAPI=2
CROS_WORKON_COMMIT="7b21a1671103d9162a9a831970c061d51d878026"
CROS_WORKON_PROJECT="chromiumos/platform/initramfs"

inherit cros-workon

DESCRIPTION="Create Chrome OS initramfs"
HOMEPAGE="http://www.chromium.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""
DEPEND="chromeos-base/vboot_reference
	chromeos-base/vpd
	media-gfx/ply-image
	sys-apps/busybox
	sys-apps/flashrom
	sys-apps/pciutils
	sys-apps/pv
	sys-fs/lvm2"
RDEPEND=""

CROS_WORKON_LOCALNAME="../platform/initramfs"

INITRAMFS_TMP_S=${WORKDIR}/initramfs_tmp
# Suffixed with cpio or not recognize filetype.
INITRAMFS_FILE="initramfs.cpio.gz"

solve_lib_symlinks() {
	local lib="$(basename "$1")"
	if ! echo "${lib}" | grep -q '\.so\.[0-9\.]*$'; then
		return
	fi
	# so_name: libpng12.so.0.45.0 -> libpng12.so
	local so_name="$(echo "${lib}" | sed 's/[0-9\.]*$//')"
	# so_rev_name: libpng12.so.0.45.0 -> libpng12.so.0
	local so_rev_name="$(echo "${lib}" |
	                     sed -r 's/(\.so\.[0-9]+)\.[0-9\.]*$/\1/')"

	ln -s "${lib}" "${INITRAMFS_TMP_S}/lib/${so_name}" || die
	if [ "${so_rev_name}" != "${lib}" ]; then
		ln -s "${lib}" "${INITRAMFS_TMP_S}/lib/${so_rev_name}" || die
	fi
}

# dobin for initramfs
idobin() {
	local src dest
	for src in "$@"; do
		if [ "${src#/}" != "${src}" ]; then
			src="${ROOT}${src}"
		else
			src="${S}/${src}"
		fi
		dest="${INITRAMFS_TMP_S}/bin/$(basename "${src}")"
		cp -p "${src}" "${dest}" && chmod a+rx "${dest}" ||
			die "Cannot install: $src"
		elog "Copied: $src"
	done
}

build_initramfs_file() {
	local dir shlib lib

	local subdirs="
		bin
		sbin
		usr/bin
		usr/sbin
		etc
		dev
		root
		proc
		sys
		usb
		newroot
		lib
		usr/lib
		stateful
		tmp
		log
	"
	for dir in $subdirs; do
		mkdir -p "${INITRAMFS_TMP_S}/$dir" || die
	done

	# Copy source files not merged from our dependencies.
	cp "${S}/init" "${INITRAMFS_TMP_S}/init" || die
	chmod +x "${INITRAMFS_TMP_S}/init"
	for shlib in *.sh; do
		cp "${S}"/${shlib} ${INITRAMFS_TMP_S}/lib || die
	done
	cp -r ${S}/screens ${INITRAMFS_TMP_S}/etc || die

	# Load libraries for busybox, dmsetup, & vbutil_kernel
	# TODO: how can ebuilds support static busybox?
	libs="
		libm.so.6
		libc.so.6
		libresolv.so.2
		libdevmapper.so.1.02
		libdl.so.2
		libpthread.so.0
		librt.so.1
                libudev.so.0
		libz.so.1
	"
	usr_libs="
		libcrypto.so.0.9.8
		libpng12.so.0.45.0
		libdrm.so.2.4.0
		libpci.so.3
	"
	gcc_libs=""
	if use x86; then
		libs="${libs} ld-linux.so.2"
		usr_libs="${usr_libs} libdrm_intel.so.1.0.0"
	elif use arm; then
		libs="${libs} ld-linux.so.3"
		gcc_libs="${gcc_libs} libgcc_s.so.1"
	fi


	for lib in ${libs}; do
		cp ${ROOT}/$(get_libdir)/${lib} ${INITRAMFS_TMP_S}/lib || die
		solve_lib_symlinks "$lib"
	done
	for lib in ${usr_libs}; do
		cp ${ROOT}/usr/$(get_libdir)/${lib} ${INITRAMFS_TMP_S}/lib || die
		solve_lib_symlinks "$lib"
	done
	for lib in ${gcc_libs}; do
		lib="$(${CHOST}-gcc -print-file-name="${lib}")" || die
		cp "${lib}" ${INITRAMFS_TMP_S}/lib || die
		solve_lib_symlinks "$lib"
	done

	# For busybox and sh
	idobin /bin/busybox
	ln -s "busybox" "${INITRAMFS_TMP_S}/bin/sh"

	# For verified rootfs
	idobin /sbin/dmsetup

	# For message screen display and progress bars
	idobin /usr/bin/ply-image
	idobin /usr/bin/pv

	# For recovery behavior
	idobin /usr/bin/tpmc
	idobin /usr/bin/dev_sign_file
	idobin /usr/bin/vbutil_kernel
	idobin /usr/bin/crossystem
	idobin /usr/bin/cgpt
	idobin /usr/bin/dump_kernel_config
	idobin /usr/sbin/vpd
	idobin /usr/sbin/flashrom

	# The 'vpd' and 'cgpt' commands are statically linked; we assert
	# as much for the protection of posterity who might otherwise be
	# forced to debug a harder problem.
	file ${ROOT}/usr/bin/cgpt | grep -q "statically linked" || die
	file ${ROOT}/usr/sbin/vpd | grep -q "statically linked" || die

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
	dodir /boot
	dobin ${WORKDIR}/${INITRAMFS_FILE}
}
