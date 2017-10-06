# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

AUTOTOOLS_AUTORECONF="yes"
inherit autotools-multilib arc-build

DESCRIPTION="ARC++ AMDGPU ADDRLIB implementation"
HOMEPAGE="http://mesa3d.sourceforge.net/"
SRC_URI="https://mesa.freedesktop.org/archive/${PV}/mesa-${PV}.tar.xz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="
	x11-libs/arc-libdrm[${MULTILIB_USEDEP}]
"
DEPEND="${RDEPEND}"

S="${WORKDIR}/mesa-${PV}"
MY_SRC="src/gallium/winsys/amdgpu/drm/addrlib/"

PATCHES=( "${FILESDIR}"/*.patch )

src_configure() {
	arc-build-select-gcc

	autotools-multilib_src_configure
}

multilib_src_configure() {
	ECONF_SOURCE="${S}" \
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
		--disable-glx \
		--enable-sysfs \
		--prefix="${ARC_PREFIX}/vendor"
}

multilib_src_compile() {
	cd "${MY_SRC}"
	default
}

multilib_src_install() {
	cd "${MY_SRC}"
	default
}
