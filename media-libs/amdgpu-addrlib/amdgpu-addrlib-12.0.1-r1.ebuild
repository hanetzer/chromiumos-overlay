# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit autotools-multilib

DESCRIPTION="AMDGPU ADDRLIB implementation"
HOMEPAGE="http://mesa3d.sourceforge.net/"
SRC_URI="https://mesa.freedesktop.org/archive/${PV}/mesa-${PV}.tar.xz"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="x11-libs/libdrm"

DEPEND="${RDEPEND}"

S="${WORKDIR}/mesa-${PV}"
MY_SRC="src/gallium/winsys/amdgpu/drm/addrlib/"

src_prepare() {
	epatch "${FILESDIR}"/*.patch
	eautoreconf
}

src_configure() {
	econf \
		--disable-option-checking \
		--disable-dependency-tracking \
		--disable-glu \
		--disable-glut \
		--disable-omx \
		--disable-va \
		--disable-vdpau \
		--disable-xvmc \
		--without-demos \
		--disable-dri3 \
		--disable-llvm-shared-libs \
		--disable-egl \
		--disable-gbm \
		--disable-egl \
		--disable-gles1 \
		--disable-gles2 \
		--disable-gbm \
		--enable-shared-glapi \
		--disable-dri \
		--disable-glx
}

src_compile() {
	cd "${MY_SRC}"
	default
}

src_install() {
	cd "${MY_SRC}"
	default
}
