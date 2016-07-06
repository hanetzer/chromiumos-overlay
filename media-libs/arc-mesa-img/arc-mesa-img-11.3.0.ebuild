# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/mesa/mesa-7.9.ebuild,v 1.3 2010/12/05 17:19:14 arfrever Exp $

EAPI=4

CROS_WORKON_COMMIT="c3b88cc2c15f19e748c9c406e9ab053975adab7e"
CROS_WORKON_TREE="286d9bc36c9a9302b6578a2d791a97f70c98ff74"

EGIT_REPO_URI="git://anongit.freedesktop.org/mesa/mesa"
CROS_WORKON_PROJECT="chromiumos/third_party/mesa"
CROS_WORKON_LOCALNAME="mesa"
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
KEYWORDS="*"

INTEL_CARDS="intel"
RADEON_CARDS="radeon"
VIDEO_CARDS="${INTEL_CARDS} ${RADEON_CARDS} mach64 mga nouveau powervr r128 savage sis vmware tdfx via freedreno"
for card in ${VIDEO_CARDS}; do
	IUSE_VIDEO_CARDS+=" video_cards_${card}"
done

IUSE="${IUSE_VIDEO_CARDS}
	+classic debug dri egl +gallium -gbm gles1 gles2 +llvm +nptl pic selinux
	shared-glapi kernel_FreeBSD xlib-glx X"

DEPEND="video_cards_powervr? ( media-libs/arc-img-ddk )
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

	epatch "${FILESDIR}"/9.1-mesa-st-no-flush-front.patch
	epatch "${FILESDIR}"/10.3-state_tracker-gallium-fix-crash-with-st_renderbuffer.patch
	epatch "${FILESDIR}"/10.3-state_tracker-gallium-fix-crash-with-st_renderbuffer-freedreno.patch
	epatch "${FILESDIR}"/9.0-i965-Allow-the-case-where-multiple-flush-types-are-e.patch
	epatch "${FILESDIR}"/8.1-array-overflow.patch
	epatch "${FILESDIR}"/10.3-fix-compile-disable-asm.patch
	epatch "${FILESDIR}"/10.3-0004-draw-Move-llvm-stuff-to-be-cached-to-new-struct.patch
	epatch "${FILESDIR}"/10.3-0005-draw-cache-LLVM-compilation.patch
	epatch "${FILESDIR}"/10.3-0006-draw-keep-some-unused-items-in-the-llvm-cache.patch
	epatch "${FILESDIR}"/10.0-no-fail-hwctx.patch
	epatch "${FILESDIR}"/9.1-renderbuffer_0sized.patch
	epatch "${FILESDIR}"/10.0-i965-Disable-ctx-gen6.patch
	epatch "${FILESDIR}"/10.3-dri-i965-Return-NULL-if-we-don-t-have-a-miptree.patch
	epatch "${FILESDIR}"/10.3-Fix-workaround-corner-cases.patch
	epatch "${FILESDIR}"/10.3-drivers-dri-i965-gen6-Clamp-scissor-state-instead-of.patch
	epatch "${FILESDIR}"/10.3-i965-remove-read-only-restriction-of-imported-buffer.patch
	epatch "${FILESDIR}"/10.3-egl-dri2-report-EXT_image_dma_buf_import-extension.patch
	epatch "${FILESDIR}"/10.3-egl-dri2-add-support-for-image-config-query.patch
	epatch "${FILESDIR}"/10.3-egl-dri2-platform_drm-should-also-try-rende.patch
	epatch "${FILESDIR}"/10.3-dri-add-swrast-support-on-top-of-prime-imported.patch
	epatch "${FILESDIR}"/10.3-dri-in-swrast-use-render-nodes-and-custom-VGEM-dump-.patch
	epatch "${FILESDIR}"/10.5-i915g-force-tile-x.patch
	epatch "${FILESDIR}"/11.4-pbuffer-surfaceless-hooks.patch
	epatch "${FILESDIR}"/11.5-meta-state-fix.patch
	epatch "${FILESDIR}"/11.6-intel-trig.patch
	epatch "${FILESDIR}"/11.7-double-buffered.patch

	# IMG patches
	epatch "${FILESDIR}"/0001-pvr-Introduce-PowerVR-DRI-driver.patch
	epatch "${FILESDIR}"/0005-dri-Add-some-new-DRI-formats-and-fourccs.patch
	epatch "${FILESDIR}"/0006-dri-Add-MT21-DRI-fourcc.patch
	epatch "${FILESDIR}"/0007-Separate-EXT_framebuffer_object-from-ARB-version.patch
	epatch "${FILESDIR}"/0008-GL_EXT_robustness-entry-points.patch
	epatch "${FILESDIR}"/0009-GL_KHR_blend_equation_advanced-entry-points.patch
	epatch "${FILESDIR}"/0014-GL_EXT_geometry_shader-entry-points.patch
	epatch "${FILESDIR}"/0016-GL_EXT_primitive_bounding_box-entry-points.patch
	epatch "${FILESDIR}"/0017-GL_EXT_tessellation_shader-entry-points.patch
	epatch "${FILESDIR}"/0018-GL_KHR_robustness-entry-points.patch
	epatch "${FILESDIR}"/0021-GL_OES_tessellation_shader-entry-points.patch
	epatch "${FILESDIR}"/0023-GL_EXT_sparse_texture-entry-points.patch
	epatch "${FILESDIR}"/0024-Add-support-for-various-GLES-extensions.patch
	epatch "${FILESDIR}"/0025-Add-EGL_IMG_context_priority-EGL-extension.patch
	epatch "${FILESDIR}"/0034-GL_EXT_shader_pixel_local_storage2-entry-points.patch
	epatch "${FILESDIR}"/0036-Add-DRI-Query-Buffers-extension.patch

	epatch "${FILESDIR}"/0100-HACK-dri-pvr-Assume-drawable-is-always-a-PBUFFER.patch
	epatch "${FILESDIR}"/0101-dri-pvr-Add-support-for-YV12.patch
	epatch "${FILESDIR}"/0102-dri-pvr-convert-format-into-bits-per-pixel-in-Alloca.patch
	epatch "${FILESDIR}"/0103-Add-a-DRI-Query-Buffers-extension-to-Mesa.patch

	# Android specific patches
	epatch "${FILESDIR}"/0500-UPSTREAM-mesa-Build-EGL-without-X11-headers-after-in.patch
	epatch "${FILESDIR}"/0501-UPSTREAM-mesa-dri-Add-shared-glapi-to-LIBADD-on-Andr.patch
	epatch "${FILESDIR}"/0502-UPSTREAM-configure.ac-Add-support-for-Android-builds.patch
	epatch "${FILESDIR}"/0503-FROMLIST-automake-egl-Android-Add-libEGL-dependencie.patch
	epatch "${FILESDIR}"/0504-dri-Add-fd-parameter-to-__DRIbuffer.patch
	epatch "${FILESDIR}"/0505-egl-android-Convert-DRI2-EGL-platform-to-use-Prime-F.patch
	epatch "${FILESDIR}"/0506-dri-common-Allow-32-bit-RGBA-RGBX-visuals.patch
	epatch "${FILESDIR}"/0507-egl-android-Do-not-ask-gralloc-for-DRM-device.patch
	epatch "${FILESDIR}"/0508-egl-dri2-Change-loading-errors-from-DEBUG-to-WARNING.patch
	epatch "${FILESDIR}"/0509-egl-android-Use-dri2_create_image_khr-instead-of-cal.patch
	epatch "${FILESDIR}"/0510-egl-android-Disable-EGL_ANDROID_framebuffer_target-f.patch
	epatch "${FILESDIR}"/0511-egl-android-Add-support-for-YV12-pixel-format.patch
	epatch "${FILESDIR}"/0512-dri-Add-YVU-formats.patch
	epatch "${FILESDIR}"/0513-platform_android-prevent-deadlock-in-droid_swap_buff.patch
	epatch "${FILESDIR}"/0514-FIXUP-egl-android-Add-support-for-YV12-pixel-format.patch
	epatch "${FILESDIR}"/0515-egl-dri2-dri2_make_current-Set-EGL-error-if-bindCont.patch

	# Android/IMG patches
	epatch "${FILESDIR}"/0600-pvr_dri-Add-RGBA-image-format.patch
	epatch "${FILESDIR}"/0601-platform_android-Set-DRI2-loader-version-to-4.patch
	epatch "${FILESDIR}"/0602-pvr_dri-Add-support-for-buffers-with-fd-but-no-name.patch
	epatch "${FILESDIR}"/0603-mesa-img-Android-build-fixups.patch
	epatch "${FILESDIR}"/0604-pvr_dri-Route-logging-messages-to-Android-logcat.patch
	epatch "${FILESDIR}"/0605-PVRDRIAllocateBuffer-Fix-test-when-allocating-buffer.patch
	epatch "${FILESDIR}"/0606-platform_android-Add-support-for-DRI-Query-Buffer-ex.patch
	epatch "${FILESDIR}"/0607-pvrimage-Do-not-recompute-strides-no-matter-the-numb.patch
	epatch "${FILESDIR}"/0608-platform_android-prevent-deadlock-in-droid_get_buffe.patch

	base_src_prepare

	eautoreconf
}

src_configure() {
	arc-build-select-gcc

	driver_enable pvr

	append-cppflags -DANDROID -DANDROID_VERSION=0x0600
	append-cxxflags "-I${ARC_SYSROOT}/usr/include/c++/4.9" -lc++

	export PKG_CONFIG="false"

	export EXPAT_LIBS="-lexpat"
	export PTHREAD_LIBS="-lc"

	export DRM_GRALLOC_CFLAGS="-I${ARC_SYSROOT}/usr/include/drm_gralloc"
	export DRM_GRALLOC_LIBS=" "

	export LIBDRM_CFLAGS="-I${ARC_SYSROOT}/usr/include/libdrm"
	export LIBDRM_LIBS="-ldrm"

	export PVR_CFLAGS=" "
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
