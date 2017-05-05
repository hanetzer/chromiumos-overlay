# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/mesa/mesa-7.9.ebuild,v 1.3 2010/12/05 17:19:14 arfrever Exp $

EAPI=4

CROS_WORKON_COMMIT="cc71c978e74bd7f35be1a7856b0c469fcc0aa3a8"
CROS_WORKON_TREE="096555f638f88331cdd4415661cd455ed4ada50f"
CROS_WORKON_PROJECT="chromiumos/third_party/mesa"
CROS_WORKON_LOCALNAME="arc-mesa"

inherit base autotools multilib flag-o-matic python toolchain-funcs cros-workon arc-build

OPENGL_DIR="xorg-x11"

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
	android-container-nyc cheets +classic debug dri egl +gallium -gbm gles1
	gles2 +llvm +nptl pic selinux shared-glapi X xlib-glx"

DEPEND="cheets? (
		x11-libs/arc-libdrm
	)"

# llvmpipe requires ARC++ _userdebug images, ARC++ _user images can't use it
# (b/33072485, b/28802929).
RDEPEND="cheets? (
		llvm? (
			!android-container-nyc? (
				chromeos-base/android-container[-cheets_user]
			)
			android-container-nyc? (
				chromeos-base/android-container-nyc[-cheets_user]
			)
		)
	)
	${DEPEND}"

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
	tc-getPROG PKG_CONFIG pkg-config

	if use !gallium && use !classic; then
		ewarn "You enabled neither classic nor gallium USE flags. No hardware"
		ewarn "drivers will be built."
	fi

	if use classic; then
	# Configurable DRI drivers
		driver_enable swrast

		# Intel code
		driver_enable video_cards_intel i915 i965

		# Nouveau code
		driver_enable video_cards_nouveau nouveau

		# ATI code
		driver_enable video_cards_radeon radeon r200
	fi

	if use gallium; then
	# Configurable gallium drivers
		if use !xlib-glx; then
			gallium_driver_enable swrast
		fi

		# Intel code
		gallium_driver_enable video_cards_intel i915

		# Nouveau code
		gallium_driver_enable video_cards_nouveau nouveau

		# ATI code
		gallium_driver_enable video_cards_radeon r300 r600

		# Freedreno code
		gallium_driver_enable video_cards_freedreno freedreno
	fi

	export LLVM_CONFIG=${SYSROOT}/usr/bin/llvm-config-host
	EGL_PLATFORM="surfaceless"

	if use cheets; then
		#
		# cheets-specific overrides
		#

		# FIXME(tfiga): Could inherit arc-build invoke this implicitly?
		arc-build-select-gcc

		# Use llvm-config coming from ARC++ build.
		if use android-container-nyc; then
			export LLVM_CONFIG="${ARC_BASE}/arc-llvm/3.8/bin/llvm-config"
		else
			# Path for MNC.
			export LLVM_CONFIG="${ARC_BASE}/arc-llvm-mesa/bin/llvm-config"
		fi

		# FIXME(tfiga): It should be possible to make at least some of these be autodetected.
		EXTRA_ARGS="
			--enable-sysfs
			--with-dri-searchpath=/system/lib/dri:/system/vendor/lib/dri
			--sysconfdir=/system/vendor/etc
			--enable-cross_compiling
			--prefix=${ARC_PREFIX}/vendor
			--libdir=\$(prefix)/lib
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
		$(use egl && echo "--with-egl-platforms=${EGL_PLATFORM}")
}


src_install_arc() {
	exeinto "${ARC_PREFIX}/vendor/lib"
	newexe lib/libglapi.so libglapi.so

	exeinto "${ARC_PREFIX}/vendor/lib/egl"
	newexe lib/libEGL.so libEGL_mesa.so
	newexe lib/libGLESv1_CM.so libGLESv1_CM_mesa.so
	newexe lib/libGLESv2.so libGLESv2_mesa.so

	exeinto "${ARC_PREFIX}/vendor/lib/dri"
	if use classic && use video_cards_intel; then
		newexe lib/i965_dri.so i965_dri.so
	fi
	if use gallium; then
		newexe lib/gallium/kms_swrast_dri.so kms_swrast_dri.so
	fi

	# Set driconf option to enable S3TC hardware decompression
	insinto "${ARC_PREFIX}/vendor/etc/"
	doins "${FILESDIR}"/drirc
}

src_install() {
	if use cheets; then
		src_install_arc
		return
	fi

	base_src_install

	# Remove redundant headers
	# GLU and GLUT
	rm -f "${D}"/usr/include/GL/glu*.h || die "Removing GLU and GLUT headers failed."
	# Glew includes
	rm -f "${D}"/usr/include/GL/{glew,glxew,wglew}.h \
		|| die "Removing glew includes failed."

	# Move libGL and others from /usr/lib to /usr/lib/opengl/blah/lib
	# because user can eselect desired GL provider.
	ebegin "Moving libGL and friends for dynamic switching"
		dodir /usr/$(get_libdir)/opengl/${OPENGL_DIR}/{lib,extensions,include}
		local x
		for x in "${D}"/usr/$(get_libdir)/libGL.{la,a,so*}; do
			if [ -f ${x} -o -L ${x} ]; then
				mv -f "${x}" "${D}"/usr/$(get_libdir)/opengl/${OPENGL_DIR}/lib \
					|| die "Failed to move ${x}"
			fi
		done
		for x in "${D}"/usr/include/GL/{gl.h,glx.h,glext.h,glxext.h}; do
			if [ -f ${x} -o -L ${x} ]; then
				mv -f "${x}" "${D}"/usr/$(get_libdir)/opengl/${OPENGL_DIR}/include \
					|| die "Failed to move ${x}"
			fi
		done
	eend $?

	dodir /usr/$(get_libdir)/dri
	insinto "/usr/$(get_libdir)/dri/"
	insopts -m0755
	# install the gallium drivers we use
	local gallium_drivers_files=( i915_dri.so nouveau_dri.so r300_dri.so r600_dri.so msm_dri.so swrast_dri.so )
	for x in ${gallium_drivers_files[@]}; do
		if [ -f "${S}/$(get_libdir)/gallium/${x}" ]; then
			doins "${S}/$(get_libdir)/gallium/${x}"
		fi
	done

	# install classic drivers we use
	local classic_drivers_files=( i810_dri.so i965_dri.so nouveau_vieux_dri.so radeon_dri.so r200_dri.so )
	for x in ${classic_drivers_files[@]}; do
		if [ -f "${S}/$(get_libdir)/${x}" ]; then
			doins "${S}/$(get_libdir)/${x}"
		fi
	done

	# Set driconf option to enable S3TC hardware decompression
	insinto "/etc/"
	doins "${FILESDIR}"/drirc
}

pkg_postinst() {
	if use cheets; then
		return
	fi

	# Switch to the xorg implementation.
	echo
	eselect opengl set --use-old ${OPENGL_DIR}
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
