# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/mesa/mesa-7.9.ebuild,v 1.3 2010/12/05 17:19:14 arfrever Exp $

EAPI=4

CROS_WORKON_PROJECT="chromiumos/third_party/mesa-img"
CROS_WORKON_LOCALNAME="mesa-img"
CROS_WORKON_BLACKLIST="1"

if [[ ${PV} = 9999* ]]; then
	GIT_ECLASS="git-2"
	EXPERIMENTAL="true"
fi

inherit base autotools multilib flag-o-matic python toolchain-funcs ${GIT_ECLASS} cros-workon arc-build

OPENGL_DIR="xorg-x11"

MY_PN="${PN/m/M}"
MY_P="${MY_PN}-${PV/_/-}"
MY_SRC_P="${MY_PN}Lib-${PV/_/-}"

FOLDER="${PV/_rc*/}"
[[ ${PV/_rc*/} == ${PV} ]] || FOLDER+="/RC"

DESCRIPTION="OpenGL-like graphic library for Linux"
HOMEPAGE="http://mesa3d.sourceforge.net/"

# Most of the code is MIT/X11.
# ralloc is LGPL-3
# GLES[2]/gl[2]{,ext,platform}.h are SGI-B-2.0
LICENSE="MIT LGPL-3 SGI-B-2.0"
SLOT="0"
KEYWORDS="~*"

INTEL_CARDS="intel"
RADEON_CARDS="radeon"
VIDEO_CARDS="${INTEL_CARDS} ${RADEON_CARDS} mach64 mga nouveau powervr r128 savage sis vmware tdfx via freedreno"
for card in ${VIDEO_CARDS}; do
	IUSE_VIDEO_CARDS+=" video_cards_${card}"
done

IUSE="${IUSE_VIDEO_CARDS}
	+classic debug dri egl +gallium -gbm gles1 gles2 +llvm +nptl pic selinux
	shared-glapi kernel_FreeBSD xlib-glx X"

DEPEND="video_cards_powervr? (
		media-libs/arc-img-ddk
		!<media-libs/arc-img-ddk-1.7
	)
"

S="${WORKDIR}/${MY_P}"

# It is slow without texrels, if someone wants slow
# mesa without texrels +pic use is worth the shot
QA_EXECSTACK="usr/lib*/opengl/xorg-x11/lib/libGL.so*"
QA_WX_LOAD="usr/lib*/opengl/xorg-x11/lib/libGL.so*"

# Think about: ggi, fbcon, no-X configs

pkg_setup() {
	# workaround toc-issue wrt #386545
	use ppc64 && append-flags -mminimal-toc
}

src_prepare() {
	# workaround for cros-workon not preserving git metadata
	if [[ ${PV} == 9999* && "${CROS_WORKON_INPLACE}" != "1" ]]; then
		echo "#define MESA_GIT_SHA1 \"git-deadbeef\"" > src/git_sha1.h
	fi

	# apply patches
	if [[ ${PV} != 9999* && -n ${SRC_PATCHES} ]]; then
		EPATCH_FORCE="yes" \
		EPATCH_SOURCE="${WORKDIR}/patches" \
		EPATCH_SUFFIX="patch" \
		epatch
	fi
	# FreeBSD 6.* doesn't have posix_memalign().
	if [[ ${CHOST} == *-freebsd6.* ]]; then
		sed -i \
			-e "s/-DHAVE_POSIX_MEMALIGN//" \
			configure.ac || die
	fi

	base_src_prepare

	eautoreconf
}

src_configure() {
	arc-build-select-gcc

	driver_enable pvr

	local android_version=$(printf "0x%04x" \
		$(((ARC_VERSION_MAJOR << 8) + ARC_VERSION_MINOR)))

	append-cppflags -DANDROID -DANDROID_VERSION=${android_version}
	append-cxxflags "-I${ARC_SYSROOT}/usr/include/c++/4.9" -lc++

	export PKG_CONFIG="false"

	export EXPAT_LIBS="-lexpat"
	export PTHREAD_LIBS="-lc"

	export PTHREADSTUBS_CFLAGS=" "
	export PTHREADSTUBS_LIBS="-lc"

	export DRM_GRALLOC_CFLAGS="-I${ARC_SYSROOT}/usr/include/drm_gralloc"
	export DRM_GRALLOC_LIBS=" "

	export LIBDRM_CFLAGS="-I${ARC_SYSROOT}/usr/include/libdrm"
	export LIBDRM_LIBS="-ldrm"

	export PVR_CFLAGS="-I${SYSROOT}/opt/google/containers/android/vendor/include"
	export PVR_LIBS="-L${SYSROOT}/opt/google/containers/android/vendor/lib -lpvr_dri_support "
	export LLVM_CONFIG=""

	./configure \
		--host=armv7a-linux-android \
		--with-sysroot=${ARC_SYSROOT} \
		--disable-option-checking \
		--with-driver=dri \
		--disable-glu \
		--disable-glut \
		--disable-omx \
		--disable-va \
		--disable-vdpau \
		--disable-xvmc \
		--without-demos \
		--enable-texture-float \
		--disable-dri3 \
		--disable-llvm-shared-libs \
		$(use_enable X glx) \
		$(use_enable llvm llvm-gallium) \
		$(use_enable egl) \
		$(use_enable gbm) \
		$(use_enable shared-glapi) \
		$(use_enable debug) \
		--enable-glx-tls \
		$(use_enable !pic asm) \
		$(use_enable !xlib-glx dri) \
		--with-dri-drivers=${DRI_DRIVERS} \
		--with-gallium-drivers=${GALLIUM_DRIVERS} \
		$(use egl && echo "--with-egl-platforms=android") \
		--enable-sysfs \
		--with-dri-searchpath=/system/lib/dri:/system/vendor/lib/dri
}

src_install() {
	exeinto /opt/google/containers/android/vendor/lib
	newexe lib/libglapi.so libglapi.so

	exeinto /opt/google/containers/android/vendor/lib/egl
	newexe lib/libEGL.so libEGL_mesa.so

	exeinto /opt/google/containers/android/vendor/lib/dri
	newexe lib/pvr_dri.so pvr_dri.so
}

# $1 - VIDEO_CARDS flag
# other args - names of DRI drivers to enable
driver_enable() {
	case $# in
		# for enabling unconditionally
		1)
			DRI_DRIVERS+=",$1"
			;;
		*)
			if use $1; then
				shift
				for i in $@; do
					DRI_DRIVERS+=",${i}"
				done
			fi
			;;
	esac
}

# $1 - VIDEO_CARDS flag
# other args - names of DRI drivers to enable
gallium_driver_enable() {
	case $# in
		# for enabling unconditionally
		1)
			GALLIUM_DRIVERS+=",$1"
			;;
		*)
			if use $1; then
				shift
				for i in $@; do
					GALLIUM_DRIVERS+=",${i}"
				done
			fi
			;;
	esac
}
