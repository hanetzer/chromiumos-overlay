# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

EGIT_REPO_URI="http://git.chromium.org/git/kernel.git"
if [ "${CHROMEOS_KERNEL}" = "kernel-qualcomm" ]; then
	# Current HEAD of kernel.git qualcomm-2.6.32 branch.
	EGIT_COMMIT="b7acb2fedc1fa8a5836de1c60377d5aee5111102"
else
	# Current HEAD of kernel.git master branch.
	EGIT_COMMIT="d4e4d17a56d83874d66b4ca3efeaaa4c0d97c338"
fi

inherit git

DESCRIPTION="Chrome OS Kernel Headers"
HOMEPAGE="http://src.chromium.org"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 arm"
IUSE=""

src_compile() {
	elog " Nothing to compile"
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
	if [ "${CHROMEOS_KERNEL}" = "kernel-qualcomm" ]; then
		if [ -r "${S}"/include/drm/kgsl_drm.h ]; then
			insinto /usr/include/drm
			doins "${S}"/include/drm/kgsl_drm.h
		fi
	fi
}
