# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

CMAKE_MAKEFILE_GENERATOR="ninja"

inherit cmake-utils

DESCRIPTION="drawElements Quality Program - an OpenGL ES testsuite"
HOMEPAGE="https://android.googlesource.com/platform/external/deqp"

# deqp-09b02... corresponds to android master deqp directory.
# https://android.googlesource.com/platform/external/deqp/+/09b0225a8a77b3d385b7dc779d2ae06f5980bba7
MY_DEQP_COMMIT='09b0225a8a77b3d385b7dc779d2ae06f5980bba7'

# When building the Vulkan CTS, dEQP requires that certain external
# dependencies be unpacked into the source tree. See ${S}/external/fetch_sources.py
# for the required dependencies.
MY_GLSLANG_COMMIT='e3aa654c4b0c761b28d7864192ca8ceea6faf70a'
MY_SPIRV_TOOLS_COMMIT='f7e63786a919040cb2e0e572d960a0650f2c2881'

SRC_URI="gs://chromeos-localmirror/distfiles/deqp-${MY_DEQP_COMMIT}.tar.gz
	https://github.com/KhronosGroup/glslang/archive/${MY_GLSLANG_COMMIT}.tar.gz -> glslang-${MY_GLSLANG_COMMIT}.tar.gz
	https://github.com/KhronosGroup/SPIRV-Tools/archive/${MY_SPIRV_TOOLS_COMMIT}.tar.gz -> SPIRV-Tools-${MY_SPIRV_TOOLS_COMMIT}.tar.gz
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE="-vulkan"

RDEPEND="
	virtual/opengles
	media-libs/minigbm
	media-libs/libpng
	vulkan? ( virtual/vulkan-icd )
"

DEPEND="${RDEPEND}
	x11-drivers/opengles-headers
	x11-libs/libX11
"

S="${WORKDIR}"

PATCHES=(
	"${FILESDIR}"/0001-targets-surfaceless-Add-support-for-Chrome-OS-surfac.patch
	"${FILESDIR}"/0002-Delete-compiler-check.patch
	"${FILESDIR}"/0003-Added-support-for-creating-pBuffer-target.patch
	"${FILESDIR}"/0004-cmake-Use-FindPNG-instead-of-find_path-find_library.patch
	"${FILESDIR}"/0005-platform-surfaceless-Add-Vulkan-support.patch
)

src_unpack() {
	default_src_unpack || die

	if use vulkan; then
		mv "glslang-${MY_GLSLANG_COMMIT}" external/glslang/src || die
		mv "SPIRV-Tools-${MY_SPIRV_TOOLS_COMMIT}" external/spirv-tools/src || die
	fi
}

src_configure() {
	# See crbug.com/585712.
	append-lfs-flags

	local de_cpu=
	case "${ARCH}" in
		x86)   de_cpu='DE_CPU_X86';;
		amd64) de_cpu='DE_CPU_X86_64';;
		arm)   de_cpu='DE_CPU_ARM';;
		arm64) de_cpu='DE_CPU_ARM_64';;
		*) die "unknown ARCH '${ARCH}'";;
	esac

	# Tell cmake to not produce rpaths. crbug.com/585715.
	local mycmakeargs=(
		-DCMAKE_SKIP_RPATH=1
		-DCMAKE_FIND_ROOT_PATH="${ROOT}"
		-DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER
		-DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY
		-DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY
		-DDE_CPU="${de_cpu}"
		-DDEQP_TARGET=surfaceless
	)

	# Use runtime loading as specified in external/deqp/Android.mk.
	append-cxxflags "-DDEQP_EGL_RUNTIME_LOAD=1"
	append-cxxflags "-DDEQP_GLES2_RUNTIME_LOAD=1"
	append-cxxflags "-DDEQP_GLES3_RUNTIME_LOAD=1"
	append-cxxflags "-DQP_SUPPORT_PNG=1"

	cmake-utils_src_configure
}

src_install() {
	# dEQP requires that the layout of its installed files match the layout
	# of its build directory. Otherwise the binaries cannot find the data
	# files.
	local deqp_dir="/usr/local/${PN}"

	# Install module binaries
	exeinto "${deqp_dir}/modules/egl"
	doexe "${BUILD_DIR}/modules/egl/deqp-egl"
	exeinto "${deqp_dir}/modules/gles2"
	doexe "${BUILD_DIR}/modules/gles2/deqp-gles2"
	exeinto "${deqp_dir}/modules/gles3"
	doexe "${BUILD_DIR}/modules/gles3/deqp-gles3"
	exeinto "${deqp_dir}/modules/gles31"
	doexe "${BUILD_DIR}/modules/gles31/deqp-gles31"
	if use vulkan; then
		exeinto "${deqp_dir}/external/vulkancts/modules/vulkan"
		doexe "${BUILD_DIR}/external/vulkancts/modules/vulkan/deqp-vk"
	fi

	# Install executors
	exeinto "${deqp_dir}/execserver"
	doexe "${BUILD_DIR}/execserver/execserver"
	doexe "${BUILD_DIR}/execserver/execserver-client"
	doexe "${BUILD_DIR}/execserver/execserver-test"
	exeinto "${deqp_dir}/executor"
	doexe "${BUILD_DIR}/executor/executor"

	# Install data files
	insinto "${deqp_dir}/modules/gles2"
	doins -r "${BUILD_DIR}/modules/gles2/gles2"
	insinto "${deqp_dir}/modules/gles3"
	doins -r "${BUILD_DIR}/modules/gles3/gles3"
	insinto "${deqp_dir}/modules/gles31"
	doins -r "${BUILD_DIR}/modules/gles31/gles31"
	if use vulkan; then
		insinto "${deqp_dir}/external/vulkancts/modules/vulkan"
		doins -r "${BUILD_DIR}/external/vulkancts/modules/vulkan/vulkan"
	fi

	# Install master control files
	insinto "${deqp_dir}/master"
	doins "android/cts/master/egl-master.txt"
	doins "android/cts/master/gles2-master.txt"
	doins "android/cts/master/gles3-master.txt"
	doins "android/cts/master/gles31-master.txt"
	if use vulkan; then
		doins "android/cts/master/vk-master.txt"
	fi
}
