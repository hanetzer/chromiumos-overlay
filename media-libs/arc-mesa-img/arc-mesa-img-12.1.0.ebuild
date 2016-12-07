# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/mesa/mesa-7.9.ebuild,v 1.3 2010/12/05 17:19:14 arfrever Exp $

EAPI=4

CROS_WORKON_COMMIT="b010fa85675b98962426fe8961466fbae2d25499"
CROS_WORKON_TREE="286d9bc36c9a9302b6578a2d791a97f70c98ff74"

EGIT_REPO_URI="git://anongit.freedesktop.org/mesa/mesa"
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
	epatch "${FILESDIR}"/11.7-double-buffered.patch

	# IMG patches
	epatch "${FILESDIR}"/0001-dri-pvr-Introduce-PowerVR-DRI-driver.patch
	epatch "${FILESDIR}"/0004-dri-Add-some-new-DRI-formats-and-fourccs.patch
	epatch "${FILESDIR}"/0005-dri-Add-MT21-DRI-fourcc.patch
	epatch "${FILESDIR}"/0006-Separate-EXT_framebuffer_object-from-ARB-version.patch
	epatch "${FILESDIR}"/0007-GL_EXT_robustness-entry-points.patch
	epatch "${FILESDIR}"/0008-GL_KHR_blend_equation_advanced-entry-points.patch
	epatch "${FILESDIR}"/0009-GL_EXT_geometry_shader-entry-points.patch
	epatch "${FILESDIR}"/0010-GL_EXT_primitive_bounding_box-entry-points.patch
	epatch "${FILESDIR}"/0011-GL_EXT_tessellation_shader-entry-points.patch
	epatch "${FILESDIR}"/0012-GL_OES_tessellation_shader-entry-points.patch
	epatch "${FILESDIR}"/0013-GL_EXT_sparse_texture-entry-points.patch
	epatch "${FILESDIR}"/0014-Add-support-for-various-GLES-extensions.patch
	epatch "${FILESDIR}"/0015-Add-EGL_IMG_context_priority-EGL-extension.patch
	epatch "${FILESDIR}"/0023-GL_EXT_shader_pixel_local_storage2-entry-points.patch
	epatch "${FILESDIR}"/0026-GL_IMG_framebuffer_downsample-entry-points.patch
	epatch "${FILESDIR}"/0027-GL_OVR_multiview-entry-points.patch
	epatch "${FILESDIR}"/0028-Add-OVR_multiview_multisampled_render_to_texture.patch
	epatch "${FILESDIR}"/0032-OpenGLES3.2-BlendBarrier.patch
	epatch "${FILESDIR}"/0033-OpenGLES3.2-PrimitiveBoundingBox.patch

	# Android specific patches
	epatch "${FILESDIR}"/0500-UPSTREAM-egl-Fix-the-bad-surface-attributes-combinat.patch
	epatch "${FILESDIR}"/0501-UPSTREAM-egl-android-Remove-unused-variables.patch
	epatch "${FILESDIR}"/0502-UPSTREAM-egl-dri2-dri2_make_current-Set-EGL-error-if.patch
	epatch "${FILESDIR}"/0503-UPSTREAM-egl-android-Check-return-value-of-dri2_get_.patch
	epatch "${FILESDIR}"/0504-UPSTREAM-egl-android-Add-some-useful-error-messages.patch
	epatch "${FILESDIR}"/0505-UPSTREAM-egl-android-Stop-leaking-DRI-images.patch
	epatch "${FILESDIR}"/0506-UPSTREAM-egl-dri2-Add-reference-count-for-dri2_egl_d.patch
	epatch "${FILESDIR}"/0507-UPSTREAM-egl-android-Remove-unused-variables-in-droi.patch
	epatch "${FILESDIR}"/0508-UPSTREAM-egl-android-Respect-buffer-mask-in-droid_im.patch
	epatch "${FILESDIR}"/0509-UPSTREAM-egl-android-Refactor-image-creation-to-sepa.patch
	epatch "${FILESDIR}"/0510-UPSTREAM-egl-android-Make-get_fourcc-accept-HAL-form.patch
	epatch "${FILESDIR}"/0511-UPSTREAM-egl-android-Add-support-for-YV12-pixel-form.patch
	epatch "${FILESDIR}"/0512-FROMLIST-egl-dri2-dri2_initialize-Do-not-reference-c.patch
	epatch "${FILESDIR}"/0513-FROMLIST-egl-android-Set-dpy-DriverData-to-NULL-on-e.patch
	epatch "${FILESDIR}"/0514-FROMLIST-egl-android-Fix-support-for-pbuffers-v2.patch
	epatch "${FILESDIR}"/0515-FROMLIST-egl-android-Make-drm_gralloc-headers-option.patch
	epatch "${FILESDIR}"/0516-CHROMIUM-egl-android-Disable-EGL_ANDROID_framebuffer.patch
	epatch "${FILESDIR}"/0517-CHROMIUM-egl-android-Support-opening-render-nodes-fr.patch
	epatch "${FILESDIR}"/0518-CHROMIUM-egl-Add-missing-flags-for-Android-builds.patch
	epatch "${FILESDIR}"/0519-CHROMIUM-egl-android-Set-EGL_MAX_PBUFFER_WIDTH-and-E.patch
	epatch "${FILESDIR}"/0520-HACK-egl-android-Handle-HAL_PIXEL_FORMAT_IMPLEMENTAT.patch
	epatch "${FILESDIR}"/0521-HACK-egl-android-Handle-HAL_PIXEL_FORMAT_YCbCr_420_8.patch
	epatch "${FILESDIR}"/0522-UPSTREAM-egl-android-query-native-window-default-wid.patch
	epatch "${FILESDIR}"/0523-UPSTREAM-egl-Update-eglext.h-v2.patch
	epatch "${FILESDIR}"/0524-UPSTREAM-egl-Rename-MESA_configless_context-bit-to-K.patch
	epatch "${FILESDIR}"/0525-UPSTREAM-egl-add-check-that-eglCreateContext-gets-a-.patch
	epatch "${FILESDIR}"/0526-UPSTREAM-egl-dri2-set-max-values-for-pbuffer-width-a.patch
	epatch "${FILESDIR}"/0527-UPSTREAM-mesa-add-missing-formats-to-driGLFormatToIm.patch
	epatch "${FILESDIR}"/0528-UPSTREAM-egl-Lock-the-display-in-_eglCreateSync-s-ca.patch
	epatch "${FILESDIR}"/0529-UPSTREAM-egl-fix-error-handling-in-_eglCreateSync.patch
	epatch "${FILESDIR}"/0530-UPSTREAM-egl-set-preserved-behavior-for-surface-only.patch

	# Android/IMG patches
	epatch "${FILESDIR}"/0601-mesa-img-Android-build-fixups.patch

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
