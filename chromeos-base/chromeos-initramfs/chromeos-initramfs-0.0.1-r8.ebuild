# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# WARNING: cros_workon cannot detect changes to files/, please ensure
# that you manually bump or make some change to the 9999 ebuild until
# this is fixed.

EAPI=2
CROS_WORKON_COMMIT="f11aca6bc8b0e67e1eecb888545da7912f59d49a"

inherit cros-workon

DESCRIPTION="Create Chrome OS initramfs"
HOMEPAGE="http://src.chromium.org"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 arm"
IUSE=""
DEPEND="app-arch/cpio
	sys-apps/busybox
	sys-fs/lvm2
	chromeos-base/vboot_reference
	chromeos-base/chromeos-installer"
RDEPEND=""

CROS_WORKON_LOCALNAME="../platform/initramfs"
CROS_WORKON_PROJECT="initramfs"

INITRAMFS_TMP_S=${WORKDIR}/initramfs_tmp
# Suffixed with cpio or not recognize filetype.
INITRAMFS_FILE="initramfs.cpio.gz"

build_initramfs_file() {
	mkdir -p ${INITRAMFS_TMP_S}/bin ${INITRAMFS_TMP_S}/sbin
	mkdir -p ${INITRAMFS_TMP_S}/usr/bin ${INITRAMFS_TMP_S}/usr/sbin
	mkdir -p ${INITRAMFS_TMP_S}/etc ${INITRAMFS_TMP_S}/dev
	mkdir -p ${INITRAMFS_TMP_S}/root ${INITRAMFS_TMP_S}/proc
	mkdir -p ${INITRAMFS_TMP_S}/sys ${INITRAMFS_TMP_S}/usb
	mkdir -p ${INITRAMFS_TMP_S}/newroot ${INITRAMFS_TMP_S}/lib
	mkdir -p ${INITRAMFS_TMP_S}/stateful ${INITRAMFS_TMP_S}/tmp
	mkdir -p ${INITRAMFS_TMP_S}/log

	# Insure cgpt is statically linked
	file ${ROOT}/usr/bin/cgpt | grep -q "statically linked" || die

	# Load libraries for busybox and dmsetup
	# TODO: how can ebuilds support static busybox?
	if use x86 ; then
		LIBS="
			ld-linux.so.2
		"
	else
		# TODO ARM: why does arm use a different dynamic linker here?
		LIBS="
			ld-linux.so.3
		"
	fi

	LIBS="${LIBS}
		libm.so.6
		libc.so.6
		../usr/lib/libcrypto.so.0.9.8
		libdevmapper.so.1.02
		libdl.so.2
		libpam.so.0
		libpam_misc.so.0
		libpthread.so.0
		librt.so.1
		libz.so.1
	"
	for lib in $LIBS; do
		cp ${ROOT}/lib/${lib} ${INITRAMFS_TMP_S}/lib/ || die
	done

	cp ${ROOT}/bin/busybox ${INITRAMFS_TMP_S}/bin || die

	# For verified rootfs
	cp ${ROOT}/sbin/dmsetup ${INITRAMFS_TMP_S}/bin || die

	# For recovery behavior
	cp ${ROOT}/usr/bin/tpmc ${INITRAMFS_TMP_S}/bin || die
	cp ${ROOT}/usr/bin/dev_sign_file ${INITRAMFS_TMP_S}/bin || die
	cp ${ROOT}/usr/bin/vbutil_kernel ${INITRAMFS_TMP_S}/bin || die

	cp ${ROOT}/usr/bin/cgpt ${INITRAMFS_TMP_S}/usr/bin || die
	cp ${ROOT}/usr/sbin/chromeos-common.sh ${INITRAMFS_TMP_S}/usr/sbin || die
	cp ${ROOT}/usr/sbin/chromeos-findrootfs ${INITRAMFS_TMP_S}/usr/sbin || die

	ln -s "busybox" "${INITRAMFS_TMP_S}/bin/sh"
	cp "${S}/init" "${INITRAMFS_TMP_S}/init" || die
	chmod +x "${INITRAMFS_TMP_S}/init"

	# The kernel emake expects the file in cpio format.
	pushd "${INITRAMFS_TMP_S}"; find . | cpio -o -H newc | gzip -9 \
		> "${WORKDIR}/${INITRAMFS_FILE}" \
		|| die "cannot package initramfs"
	popd
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
