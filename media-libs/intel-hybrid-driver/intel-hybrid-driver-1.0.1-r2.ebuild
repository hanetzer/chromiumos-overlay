# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit autotools eutils

DESCRIPTION="Intel hybrid driver provides support for WebM project VPx codecs. GPU acceleration
is provided via media kernels executed on Intel GEN GPUs.  The hybrid driver provides the CPU
bound entropy (e.g., CPBAC) decoding and manages the GEN GPU media kernel parameters and buffers."
HOMEPAGE="https://github.com/01org/intel-hybrid-driver"
SRC_URI="https://github.com/01org/intel-hybrid-driver/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="1"
KEYWORDS="-* amd64 x86"

RDEPEND="x11-libs/libva:1
	x11-libs/libdrm
	media-libs/cmrt"

DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_prepare() {
	# pkgconfig files are named libva1
	sed -e 's/\(PKG_CONFIG.*libva\)/\11/g' -i configure.ac || die
	sed -e 's/\(PKG_CHECK_MODULES.*libva\)/\11/g' -i configure.ac || die
	# headers are in /usr/include/va1
	sed -e 's/#include <va\//#include <va1\/va\//g' -i $(find -name *.[ch]) || die
	eautoreconf
}

src_configure() {
	# Explicitly restrict configuration for Ozone/Freon.
	econf \
		--enable-drm \
		--disable-x11 \
		--disable-wayland
}

src_install() {
	default
	prune_libtool_files
}
