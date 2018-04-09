# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/mesa/mesa-7.9.ebuild,v 1.3 2010/12/05 17:19:14 arfrever Exp $

EAPI=5

CROS_WORKON_COMMIT="6874b953f6f9762fd8e7abf959aed09ab15693c5"
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
	cheets +classic debug dri egl -gallium -gbm gles1
	gles2 -llvm +nptl pic selinux shared-glapi vulkan X xlib-glx"


DEPEND="video_cards_powervr? (
		media-libs/arc-img-ddk
		!<media-libs/arc-img-ddk-1.9
	)
	cheets? (
		x11-libs/arc-libdrm
	)
"
RDEPEND="${DEPEND}"

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
	epatch "${FILESDIR}"/8.1-array-overflow.patch
	epatch "${FILESDIR}"/10.3-fix-compile-disable-asm.patch
	epatch "${FILESDIR}"/9.1-renderbuffer_0sized.patch
	epatch "${FILESDIR}"/10.0-i965-Disable-ctx-gen6.patch
	epatch "${FILESDIR}"/10.3-dri-i965-Return-NULL-if-we-don-t-have-a-miptree.patch
	epatch "${FILESDIR}"/10.3-Fix-workaround-corner-cases.patch
	epatch "${FILESDIR}"/10.3-drivers-dri-i965-gen6-Clamp-scissor-state-instead-of.patch
	epatch "${FILESDIR}"/10.3-i965-remove-read-only-restriction-of-imported-buffer.patch
	epatch "${FILESDIR}"/11.5-meta-state-fix.patch
	epatch "${FILESDIR}"/12.1-radeonsi-sampler_view_destroy.patch
	epatch "${FILESDIR}"/17.0-glcpp-Hack-to-handle-expressions-in-line-di.patch
	epatch "${FILESDIR}"/17.0-CHROMIUM-disable-hiz-on-braswell.patch

	# IMG patches
	epatch "${FILESDIR}"/0001-dri-pvr-Introduce-PowerVR-DRI-driver.patch
	epatch "${FILESDIR}"/0003-dri-Add-some-new-DRI-formats-and-fourccs.patch
	epatch "${FILESDIR}"/0004-dri-Add-MT21-DRI-fourcc.patch
	epatch "${FILESDIR}"/0005-Separate-EXT_framebuffer_object-from-ARB-version.patch
	epatch "${FILESDIR}"/0006-GL_EXT_robustness-entry-points.patch
	epatch "${FILESDIR}"/0007-GL_EXT_sparse_texture-entry-points.patch
	epatch "${FILESDIR}"/0008-Add-support-for-various-GLES-extensions.patch
	epatch "${FILESDIR}"/0009-Add-EGL_IMG_context_priority-EGL-extension.patch
	epatch "${FILESDIR}"/0016-GL_EXT_shader_pixel_local_storage2-entry-points.patch
	epatch "${FILESDIR}"/0018-GL_IMG_framebuffer_downsample-entry-points.patch
	epatch "${FILESDIR}"/0019-GL_OVR_multiview-entry-points.patch
	epatch "${FILESDIR}"/0020-Add-OVR_multiview_multisampled_render_to_texture.patch
	epatch "${FILESDIR}"/0026-GL_IMG_bindless_texture-entry-points.patch
	epatch "${FILESDIR}"/0028-egl-automatically-call-eglReleaseThread-on-thread-te.patch

	# Android specific patches
	epatch "${FILESDIR}"/0500-CHROMIUM-egl-android-Add-fallback-to-kms_swrast-driv.patch
	epatch "${FILESDIR}"/0501-CHROMIUM-egl-android-Make-drm_gralloc-headers-option.patch
	epatch "${FILESDIR}"/0502-CHROMIUM-egl-android-Support-opening-render-nodes-fr.patch
	epatch "${FILESDIR}"/0503-FROMLIST-egl-android-remove-HAL_PIXEL_FORMAT_BGRA_88.patch
	epatch "${FILESDIR}"/0504-HACK-egl-android-Partially-handle-HAL_PIXEL_FORMAT_I.patch
	epatch "${FILESDIR}"/0505-UPSTREAM-egl-deduplicate-swap-interval-clamping-logi.patch
	epatch "${FILESDIR}"/0506-UPSTREAM-loader-remove-clamp_swap_interval.patch
	epatch "${FILESDIR}"/0507-UPSTREAM-egl-make-platform-s-SwapInterval-optional.patch
	epatch "${FILESDIR}"/0508-FROMLIST-egl-dri2-Implement-swapInterval-fallback-in.patch
	epatch "${FILESDIR}"/0509-UPSTREAM-i965-miptree-Set-supports_fast_clear-false-.patch
	epatch "${FILESDIR}"/0510-UPSTREAM-i965-Only-call-create_for_planar_image-for-.patch
	epatch "${FILESDIR}"/0511-UPSTREAM-egl-android-Provide-an-option-for-the-backe.patch

	# Android/IMG patches
	epatch "${FILESDIR}"/0601-mesa-img-Android-build-fixups.patch

	base_src_prepare

	eautoreconf
}

src_configure() {
	tc-getPROG PKG_CONFIG pkg-config

	driver_enable pvr

	export LLVM_CONFIG=${SYSROOT}/usr/bin/llvm-config-host
	EGL_PLATFORM="surfaceless"

	if use cheets; then
		#
		# cheets-specific overrides
		#

		# FIXME(tfiga): Could inherit arc-build invoke this implicitly?
		arc-build-select-clang

		# Use llvm-config coming from ARC++ build.
		# TODO(b/65414758): Switch to locally built LLVM when it's ready.
		export LLVM_CONFIG="${ARC_BASE}/arc-llvm/${ARC_LLVM_VERSION}/bin/llvm-config"

		# FIXME(tfiga): It should be possible to make at least some of these be autodetected.
		EXTRA_ARGS="
			--enable-sysfs
			--with-dri-searchpath=/system/$(get_libdir)/dri:/system/vendor/$(get_libdir)/dri
			--sysconfdir=/system/vendor/etc
			--enable-cross_compiling
			--prefix=${ARC_PREFIX}/vendor
		"
		# FIXME(tfiga): Possibly use flag?
		EGL_PLATFORM="android"

		#
		# end of arc-mesa specific overrides
		#
	fi

	if ! use llvm; then
		export LLVM_CONFIG="no"
	fi

	# TODO(drinkcat): We should provide a pkg-config file for this.
	export PVR_CFLAGS="-I${SYSROOT}${ARC_PREFIX}/vendor/include"
	export PVR_LIBS="-L${SYSROOT}${ARC_PREFIX}/vendor/lib -lcutils -llog -lpvr_dri_support "

	econf \
		${EXTRA_ARGS} \
		--disable-option-checking \
		--with-driver=dri \
		--disable-glu \
		--disable-glut \
		--disable-omx \
		--disable-va \
		--disable-vdpau \
		--disable-xvmc \
		--disable-asm \
		--without-demos \
		--enable-texture-float \
		--disable-dri3 \
		$(use_enable llvm llvm-shared-libs) \
		$(use_enable X glx) \
		$(use_enable llvm gallium-llvm) \
		$(use_enable egl) \
		$(use_enable gbm) \
		$(use_enable gles1) \
		$(use_enable gles2) \
		$(use_enable shared-glapi) \
		$(use_enable gallium) \
		$(use_enable debug) \
		$(use_enable nptl glx-tls) \
		$(use_enable xlib-glx) \
		$(use_enable !xlib-glx dri) \
		--with-dri-drivers=${DRI_DRIVERS} \
		--with-gallium-drivers=${GALLIUM_DRIVERS} \
		--with-vulkan-drivers=${VULKAN_DRIVERS} \
		$(use egl && echo "--with-egl-platforms=${EGL_PLATFORM}")
}

src_install() {
	exeinto "${ARC_PREFIX}/vendor/$(get_libdir)"
	newexe $(get_libdir)/libglapi.so libglapi.so

	exeinto "${ARC_PREFIX}/vendor/$(get_libdir)/egl"
	newexe $(get_libdir)/libEGL.so libEGL_mesa.so
	newexe $(get_libdir)/libGLESv1_CM.so libGLESv1_CM_mesa.so
	newexe $(get_libdir)/libGLESv2.so libGLESv2_mesa.so

	exeinto "${ARC_PREFIX}/vendor/$(get_libdir)/dri"
	newexe $(get_libdir)/pvr_dri.so pvr_dri.so
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

gallium_enable() {
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

vulkan_enable() {
	case $# in
		# for enabling unconditionally
		1)
			VULKAN_DRIVERS+=",$1"
			;;
		*)
			if use $1; then
				shift
				for i in $@; do
					VULKAN_DRIVERS+=",${i}"
				done
			fi
			;;
	esac
}
