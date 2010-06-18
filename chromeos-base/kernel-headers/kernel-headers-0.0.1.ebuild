# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit toolchain-funcs

DESCRIPTION="Chrome OS Kernel Headers"
HOMEPAGE="http://src.chromium.org"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 arm"
IUSE=""

DEPEND="sys-apps/debianutils"
RDEPEND="${DEPEND}"

kernel=${CHROMEOS_KERNEL:-"kernel/files"}
files="${CHROMEOS_ROOT}/src/third_party/${kernel}"

src_unpack() {
	elog "Using kernel files: ${files}"

	mkdir -p "${S}"
	cp -ar "${files}"/* "${S}" || die
}

src_configure() {
	elog "Nothing to configure."
}

src_compile() {
	elog "Nothing to compile."
}

src_install() {
	emake \
	  ARCH=$(tc-arch-kernel) \
	  CROSS_COMPILE="${CHOST}-" \
	  INSTALL_HDR_PATH="${D}"/usr \
	  headers_install || die

	#
	# These subdirectories are installed by various ebuilds and we don't
	# want to conflict with them.
	#
	rm -rf "${D}"/usr/include/sound
	rm -rf "${D}"/usr/include/scsi
	rm -rf "${D}"/usr/include/drm

	#
	# Double hack, install the Qualcomm drm header anyway, its not included in
	# libdrm, and is required to build xf86-video-msm.
	#
	if [ -r "${S}"/include/drm/kgsl_drm.h ]; then
		insinto /usr/include/drm
		doins "${S}"/include/drm/kgsl_drm.h
	fi
}
