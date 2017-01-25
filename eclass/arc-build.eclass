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

	# Setup internal variables
	if use android-container-nyc; then
		ARC_BASE="/opt/android-n"
		export ARC_VERSION_MAJOR="7"
		export ARC_VERSION_MINOR="1"
		export ARC_VERSION_PATCH="0"
	else
		ARC_BASE="/opt/android"
		export ARC_VERSION_MAJOR="6"
		export ARC_VERSION_MINOR="0"
		export ARC_VERSION_PATCH="1"
	fi

	case ${ARCH} in
	arm)
		ARC_GCC_TUPLE=arm-linux-androideabi
		ARC_GCC_BASE="${ARC_BASE}/arc-gcc/arm/${ARC_GCC_TUPLE}-4.9"
		ARC_GCC_LIBDIR="${ARC_BASE}/lib/gcc/${ARC_GCC_TUPLE}/4.9"

		export CHOST="${ARC_GCC_TUPLE}"
		;;
	amd64)
		ARC_GCC_TUPLE=x86_64-linux-android
		ARC_GCC_BASE="${ARC_BASE}/arc-gcc/x86_64/${ARC_GCC_TUPLE}-4.9"
		ARC_GCC_LIBDIR="${ARC_BASE}/lib/gcc/${ARC_GCC_TUPLE}/4.9"

		# Our host is in fact i686. Toolchain binaries are specified
		# with CC and CXX.
		export CHOST=i686-linux-android

		# Use 32-bit ABI on amd64 builds
		append-flags -m32
		append-ldflags -m32
		;;
	esac

	export ARC_PREFIX="/opt/google/containers/android"
	export ARC_SYSROOT="${ARC_BASE}/${ARCH}"
	export PKG_CONFIG="${ARC_BASE}/pkg-config-arc ${ARCH}"

	# Strip out flags that are specific to our compiler wrapper.
	filter-flags -clang-syntax

	# Android uses soft floating point still.
	filter-flags -mfpu=neon -mfloat-abi=hard

	# Set up flags for the android sysroot.
	append-flags --sysroot="${ARC_SYSROOT}"
	local android_version=$(printf "0x%04x" \
		$(((ARC_VERSION_MAJOR << 8) + ARC_VERSION_MINOR)))
	append-cppflags -DANDROID -DANDROID_VERSION=${android_version}
	append-cxxflags -I${ARC_SYSROOT}/usr/include/c++/4.9 -lc++
}

# Set up the compiler settings for GCC.
arc-build-select-gcc() {
	_arc-build-select-common

	export CC="${ARC_GCC_BASE}/bin/${ARC_GCC_TUPLE}-gcc"
	export CXX="${ARC_GCC_BASE}/bin/${ARC_GCC_TUPLE}-g++"
}

# Set up the compiler settings for clang.
arc-build-select-clang() {
	_arc-build-select-common

	ARC_CLANG_BASE="${ARC_BASE}/arc-llvm/3.8/bin"

	export CC="${ARC_CLANG_BASE}/clang"
	export CXX="${ARC_CLANG_BASE}/clang++"

	local target
	case ${ARCH} in
	arm) target="arm-linux-androideabi" ;;
	esac
	CC+=" -target ${target} -B${ARC_GCC_BASE}/bin"
	CXX+=" -target ${target} -B${ARC_GCC_BASE}/bin"

	append-ldflags -L"${ARC_GCC_LIBDIR}"
}

# If your ebuild declares src_prepare, you'll need to call this directly.
# It will set up CC/CXX for use w/gcc.
arc-build_src_prepare() {
	arc-build-select-gcc
}

EXPORT_FUNCTIONS src_prepare

fi
