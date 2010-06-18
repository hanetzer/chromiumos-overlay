# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit cros-workon

DESCRIPTION="Chrome OS Kernel Headers"
HOMEPAGE="http://src.chromium.org"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE=""

DEPEND="sys-apps/debianutils"
RDEPEND="${DEPEND}"

CROS_WORKON_LOCALNAME="kernel"
CROS_WORKON_SUBDIR="files"

src_unpack() {
	# Set category to force cros-workon_src_unpack go to the right
	# directory.
        CATEGORY="kernel"
        cros-workon_src_unpack
}

src_compile() {
      :  # Ensure it does not try to run make here.
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
	for d in sound scsi drm; do
	    local target="${D}"/usr/include/"${d}"
	    if [ -d ${target} ]; then
	        rm -rf ${target}
	    fi
	done

	#
	# Double hack, install the Qualcomm drm header anyway, its not included in
	# libdrm, and is required to build xf86-video-msm.
	#
	if [ -r "${S}"/include/drm/kgsl_drm.h ]; then
		insinto /usr/include/drm
		doins "${S}"/include/drm/kgsl_drm.h || die
	fi
}
