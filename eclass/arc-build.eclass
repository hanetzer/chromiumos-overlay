# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: arc-build.eclass
# @MAINTAINER:
# Chromium OS Build Team
# @BUGREPORTS:
# Please report bugs via http://crbug.com/new (with label Build)
# @VCSURL: https://chromium.googlesource.com/chromiumos/overlays/chromiumos-overlay/+/master/eclass/@ECLASS@
# @BLURB: helper eclass for building packages to run under ARC (Android Runtime)
# @DESCRIPTION:
# We want to build some libraries to run under ARC.  These funcs will help
# write ebuilds to accomplish that.

if [[ -z ${_ARC_BUILD_ECLASS} ]]; then
_ARC_BUILD_ECLASS=1

# Check for EAPI 4+.
case "${EAPI:-0}" in
4|5|6) ;;
*) die "unsupported EAPI (${EAPI}) in eclass (${ECLASS})" ;;
esac

inherit flag-o-matic

IUSE="-android-container-nyc"

# These are internal variables the user should not need to mess with.

if use android-container-nyc; then
	ARC_BASE="/opt/android-n"
else
	ARC_BASE="/opt/android"
fi

ARC_CLANG_BASE="${ARC_BASE}/arc-llvm/3.8/bin"

ARC_GCC_BASE="${ARC_BASE}/arc-gcc"
ARC_GCC_ARM_BASE="${ARC_GCC_BASE}/arm/arm-linux-androideabi-4.9"
ARC_GCC_ARM_BINDIR="${ARC_GCC_ARM_BASE}/bin"
ARC_GCC_ARM_LIBDIR="${ARC_GCC_ARM_BASE}/lib/gcc/arm-linux-androideabi/4.9"
ARC_GCC_ARM_PREFIX="${ARC_GCC_ARM_BINDIR}/arm-linux-androideabi-"

ARC_GCC_X86_64_BASE="${ARC_GCC_BASE}/x86_64/x86_64-linux-android-4.9"
ARC_GCC_X86_64_BINDIR="${ARC_GCC_X86_64_BASE}/bin"
ARC_GCC_X86_64_LIBDIR="${ARC_GCC_X86_64_BASE}/lib/gcc/x86_64-linux-android/4.9"
ARC_GCC_X86_64_PREFIX="${ARC_GCC_X86_64_BINDIR}/x86_64-linux-android-"

ARC_SYSROOT_BASE="${ARC_BASE}"

# Make sure we know how to handle the active system.
arc-build-check-arch() {
	case ${ARCH} in
	arm|amd64) ;;
	*) die "Unsupported arch ${ARCH}" ;;
	esac
}

_arc-build-select-common() {
	if [[ -n ${ARC_SYSROOT} ]] ; then
		# If we've already been set up, don't re-run.
		return 0
	fi

	arc-build-check-arch

	# Set up flags for the android sysroot.
	export ARC_SYSROOT="${ARC_SYSROOT_BASE}/${ARCH}"
	append-flags --sysroot="${ARC_SYSROOT}"

	export PKG_CONFIG="${ARC_BASE}/pkg-config-arc ${ARCH}"

	# Strip out flags that are specific to our compiler wrapper.
	filter-flags -clang-syntax

	# Android uses soft floating point still.
	filter-flags -mfpu=neon -mfloat-abi=hard
}

# Set up the compiler settings for GCC.
arc-build-select-gcc() {
	case ${ARCH} in
	arm)
		export CC="${ARC_GCC_ARM_PREFIX}gcc"
		export CXX="${ARC_GCC_ARM_PREFIX}g++"
		;;
	amd64)
		export CC="${ARC_GCC_X86_64_PREFIX}gcc"
		export CXX="${ARC_GCC_X86_64_PREFIX}g++"
		;;
	esac

	_arc-build-select-common
}

# Set up the compiler settings for clang.
arc-build-select-clang() {
	export CC="${ARC_CLANG_BASE}/clang"
	export CXX="${ARC_CLANG_BASE}/clang++"

	local target
	case ${ARCH} in
	arm) target="arm-linux-androideabi" ;;
	esac
	CC+=" -target ${target} -B${ARC_GCC_ARM_BINDIR}"
	CXX+=" -target ${target} -B${ARC_GCC_ARM_BINDIR}"

	append-ldflags -L"${ARC_GCC_ARM_LIBDIR}"

	_arc-build-select-common
}

# If your ebuild declares src_prepare, you'll need to call this directly.
# It will set up CC/CXX for use w/gcc.
arc-build_src_prepare() {
	arc-build-select-gcc
}

EXPORT_FUNCTIONS src_prepare

fi
