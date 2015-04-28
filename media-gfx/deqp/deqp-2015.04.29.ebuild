# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

CMAKE_MAKEFILE_GENERATOR="ninja"

inherit cmake-utils

DESCRIPTION="drawElements Quality Program - an OpenGL ES testsuite"
HOMEPAGE="https://android.googlesource.com/platform/external/deqp"
SRC_URI="gs://chromeos-localmirror/distfiles/deqp-c6ed49223fcf746706f9cf6a78e71022592f56d5.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="
	virtual/opengles
	media-libs/minigbm
	media-libs/libpng
"

DEPEND="${RDEPEND}"

S="${WORKDIR}"

PATCHES=(
	"${FILESDIR}"/cmake-Use-FindPNG-instead-of-find_path-find_library.patch
	"${FILESDIR}"/targets-drm-Add-new-target-to-support-Chrome-OS-s-EGL-null-platform.patch
)

src_configure() {
	local de_cpu=
	case "${ARCH}" in
		x86)   de_cpu='DE_CPU_X86';;
		amd64) de_cpu='DE_CPU_X86_64';;
		arm)   de_cpu='DE_CPU_ARM';;
		arm64) de_cpu='DE_CPU_ARM_64';;
		*) die "unknown ARCH '${ARCH}'";;
	esac

	local mycmakeargs=(
		-DCMAKE_FIND_ROOT_PATH="${SYSROOT}"
		-DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER
		-DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY
		-DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY

		-DDE_CPU="${de_cpu}"
		-DDEQP_TARGET=drm
	)

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
}
