#!/bin/bash
#
# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
#
# This script creates a tarball that contains toolchains for android N.
# Before running it, please modify the following 4 variables
#   - ANDROID_TREE
#   - ARTIFACTS_DIR_ARM
#   - ARTIFACTS_DIR_X86_64
#   - TO_DIR_BASE
# Then just run it from anywhere with no arguments.
# The constructed tarball will contain the sysroots under amd64 and arm.
#
# *** PREREQUISITES ***
# Before running the script, follow these steps:
#
# 1. Download prebuilts for ARM and x86_64
#
# Go to go/a-b, select branch git_nyc-mr1-arc. Pick a -userdebug build for all
# architectures, then download cheets_${arch}-target_files-${build_id}.zip.
# Extract those files and point ARTIFACTS_DIR_${ARCH} to the respective
# directories.
# The prebuilts will provide most of the binaries.
#
# 2. Make sure you have the right version of the prebuilts
#
# $ grep "ro.build.version.release" ${ARTIFACTS_DIR_${ARCH}}/SYSTEM/build.prop
#
# 3. Run the script!
#
# $ ./gather.sh
#


set -e

# 1. Location of the android nyc-arc branch tree.
: "${ANDROID_TREE:="${HOME}/android"}"

# ARCH names used in sysroot.
ARC_ARCH=('amd64' 'arm' 'amd64')

# LIBRARY paths for each ARCH
ARC_ARCH_LIB_DIR=('lib' 'lib' 'lib64')

# ARCH names used in android.
ARC_ARCH_ANDROID=('x86' 'arm' 'x86_64')

# ARCH names used in libm
ARC_ARCH_LIBM=('i387' 'arm' 'amd64')

# ARCH names used in kernel uapi.
ARC_ARCH_UAPI=('x86' 'arm' 'x86')

# 2. The dir to which the artifacts tarball (downloaded from go/a-b) was
# extracted. Pick a -userdebug build.
# Now we support two platforms: 32-bit arm and 32/64-bit x86.
: "${ARTIFACTS_DIR_ARM:="${ANDROID_TREE}/arm_target_files/"}"
: "${ARTIFACTS_DIR_X86_64:="${ANDROID_TREE}/x86_64_target_files/"}"

ARTIFACTS_DIR_ARRAY=(
	"${ARTIFACTS_DIR_X86_64}"
	"${ARTIFACTS_DIR_ARM}"
	"${ARTIFACTS_DIR_X86_64}"
)

# 3. Destination directory.
TO_DIR_BASE="${TO_DIR_BASE:-"${ANDROID_TREE}/arc-toolchain-n-dir"}"


### Do not change the following.

if [[ ! -d "${ANDROID_TREE}" ]] || \
	[[ ! -d "${ARTIFACTS_DIR_ARM}" ]] || \
	[[ ! -d "${ARTIFACTS_DIR_X86_64}" ]] ; then
	echo "Please open and edit \"$0\" before running."
	exit 1
fi

dryrun=
if [[ "$1" == "--dryrun" ]]; then
	dryrun=1
fi


### Run / dryrun a command.
function runcmd {
	cmdarray=("${@}")
	if [[ -z "${dryrun}" ]]; then
		echo "${cmdarray[@]}"
		"${cmdarray[@]}"
	else
		echo "dryrun: ${cmdarray[@]}"
	fi
}


# Clean any previous work.
if [ -d "${TO_DIR_BASE}" ]; then
	runcmd rm -rf "${TO_DIR_BASE}"
fi

# Number of supported sysroots
len=$((${#ARC_ARCH[@]}))

# Setup the sysroot for each architecture.
for (( a = 0; a < ${len}; ++a )); do
	arc_arch="${ARC_ARCH[${a}]}"
	arch="${ARC_ARCH_ANDROID[${a}]}"

	arch_to_dir="${TO_DIR_BASE}/${arc_arch}"
	runcmd mkdir -p "${arch_to_dir}/usr/include"
	runcmd mkdir -p "${arch_to_dir}/usr/include/asm"
	runcmd mkdir -p "${arch_to_dir}/usr/include/c++/4.9"
	runcmd mkdir -p "${arch_to_dir}/usr/include/linux/asm"

	### 1. Binaries.
	BINARY_FILES=(
		libbinder.so
		libc.so
		libc++.so
		libcutils.so
		libdl.so
		libexpat.so
		libhardware.so
		liblog.so
		libm.so
		libstdc++.so
		libsync.so
		libui.so
		libutils.so
		libz.so
		crtbegin_so.o
		crtend_so.o
	)

	lib="${ARC_ARCH_LIB_DIR[${a}]}"
	artifacts_system_dir="${ARTIFACTS_DIR_ARRAY[${a}]}/SYSTEM/${lib}"
	if [[ ! -d "${artifacts_system_dir}" ]]; then
		echo "${artifacts_system_dir} not found, continuing."
		continue
	fi
	runcmd mkdir -p "${arch_to_dir}/usr/${lib}/"

	for f in "${BINARY_FILES[@]}"; do
		file=$(find "${artifacts_system_dir}" -name "${f}" 2>/dev/null)
		case $(echo "${file}" | wc -l) in
		0)
			echo "${f} not found, aborted."
			exit 1
			;;
		1) ;;
		*)
			echo "more than 1 ${f} found, aborted."
			echo "${file}"
			exit 1
			;;
		esac

		runcmd cp -p "${file}" "${arch_to_dir}/usr/${lib}/"
	done

	for f in crtbegin_static.o crtbegin_dynamic.o crtend_android.o; do
		absolute_f="${ANDROID_TREE}/prebuilts/ndk/current/platforms/android-24"
		absolute_f+="/arch-${arch}/usr/${lib}/${f}"
		if [[ ! -e "${absolute_f}" ]]; then
			echo "${absolute_f} not found, perhaps you forgot to check it out?"\
				" Aborted."
			exit 1
		fi
		runcmd cp -p "${absolute_f}" "${arch_to_dir}/usr/${lib}/"
	done


	### 2. Bionic headers.
	for f in libc libm; do
		runcmd \
			cp -pPR \
			"${ANDROID_TREE}/bionic/${f}/include"/* \
			"${arch_to_dir}/usr/include/"
	done
	runcmd cp -pP \
		"${ANDROID_TREE}/bionic/libc/upstream-netbsd/android/include/sys/sha1.h" \
		"${arch_to_dir}/usr/include/"


	### 3. Libcxx headers.
	CXX_HEADERS_DIR="${arch_to_dir}/usr/include/c++/4.9"
	runcmd cp -pPR \
		"${ANDROID_TREE}/external/libcxx/include/"* \
		"${CXX_HEADERS_DIR}/"


	### 4.1 Linux headers.
	for f in linux asm-generic drm misc mtd rdma scsi sound video xen; do
		runcmd cp -pPR \
			"${ANDROID_TREE}/bionic/libc/kernel/uapi/${f}" \
			"${arch_to_dir}/usr/include/"
	done


	### 4.2 Linux kernel assembly.
	runcmd cp -pPR \
		"${ANDROID_TREE}/bionic/libc/kernel/uapi/asm-${ARC_ARCH_UAPI[${a}]}/asm"/* \
		"${arch_to_dir}/usr/include/asm/"


	### 4.3a Other include directories
	INCLUDE_DIRS=(
		"frameworks/native/include/android"
		"frameworks/native/include/ui"
		"frameworks/native/vulkan/include/hardware"
		"frameworks/native/vulkan/include/vulkan"
		"hardware/libhardware/include/hardware"
		"system/core/include/android"
		"system/core/include/cutils"
		"system/core/include/log"
		"system/core/include/system"
		"system/core/include/utils"
		"system/core/libsync/include/sync"
	)

	for f in "${INCLUDE_DIRS[@]}"; do
		basename="$(basename "${f}")"
		todir="${arch_to_dir}/usr/include/${basename}"
		runcmd mkdir -p "${todir}"
		runcmd cp -pP "${ANDROID_TREE}/${f}"/*.h "${todir}/"
	done

	### 4.3b Other include directories (arch-specific)
	INCLUDE_DIRS=(
		"bionic/libc/arch-${arch}/include/machine"
		"bionic/libm/include/${ARC_ARCH_LIBM[${a}]}/machine"
	)

	for f in "${INCLUDE_DIRS[@]}"; do
		todir="${arch_to_dir}/usr/include/arch-${arch}/include/machine"
		runcmd mkdir -p "${todir}"
		runcmd cp -pP "${ANDROID_TREE}/${f}"/*.h "${todir}/"
	done

	### 4.4 Expat includes

	runcmd cp -pP \
		"${ANDROID_TREE}/external/expat/lib"/expat*.h \
		"${arch_to_dir}/usr/include/"

	### 4.5 OpenGL includes

	for f in EGL KHR; do
		todir="${arch_to_dir}/usr/include/opengl/include/${f}/"
		runcmd mkdir -p "${todir}"
		runcmd cp -pP \
			"${ANDROID_TREE}/frameworks/native/opengl/include/${f}"/*.h \
			"${todir}"
	done

	### 4.6 zlib includes

	# Do not use -P (those are symlinks)
	runcmd cp -p \
		"${ANDROID_TREE}/external/zlib"/*.h \
		"${arch_to_dir}/usr/include/"

done

### 5. Copy compiler over.

### 5.1 clang.
runcmd mkdir -p "${TO_DIR_BASE}/arc-llvm/3.8"
runcmd cp -pPr \
	"${ANDROID_TREE}/prebuilts/clang/host/linux-x86/clang-2690385"/* \
	"${TO_DIR_BASE}/arc-llvm/3.8"

### 5.2 gcc.
runcmd mkdir -p "${TO_DIR_BASE}/arc-gcc"
for arch in "${ARC_ARCH_ANDROID[@]}"; do
	arch_dir="${arch}"
	sysroot_arch="${arch}"
	abi="${arch}-linux-androideabi"
	if [[ "${arch}" == "x86" || "${arch}" == "x86_64" ]]; then
		arch="x86"
		arch_dir="x86_64"
		sysroot_arch="amd64"
		abi="x86_64-linux-android"
	fi
	gcc_dir="${TO_DIR_BASE}/arc-gcc/${arch_dir}"
	runcmd mkdir -p "${gcc_dir}"
	runcmd rsync -a --exclude=.git/ \
		"${ANDROID_TREE}/prebuilts/gcc/linux-x86/${arch}/${abi}-4.9" \
		"${gcc_dir}/"

	runcmd mkdir -p "${gcc_dir}/${abi}-4.9/include/c++"
	if [ ! -L "${gcc_dir}/${abi}-4.9/include/c++/4.9" ]; then
		runcmd ln -s \
			"../../../../../${sysroot_arch}/usr/include/c++/4.9/" \
			"${gcc_dir}/${abi}-4.9/include/c++/4.9"
	fi
done

### 6. Do the pack

### 6.1. Ensure permissions are correct to avoid repeating crbug.com/811217
runcmd find "${TO_DIR_BASE}" -type d -exec chmod 755 {} \;
runcmd find "${TO_DIR_BASE}" -type f -executable -exec chmod 755 {} \;
runcmd find "${TO_DIR_BASE}" -type f ! -executable -exec chmod 644 {} \;

### 6.2. Create the tarball with files owned by root:root
PACKET_VERSION=$(date --rfc-3339=date | sed 's/-/./g')
TARBALL="${TO_DIR_BASE}/../arc-toolchain-n-${PACKET_VERSION}.tar.gz"
runcmd tar zcf "${TARBALL}" --owner=root --group=root -C "${TO_DIR_BASE}" .

### 7. Manually upload
### Or you try this command: gsutil cp -a public-read arc-toolchain-* gs://chromeos-localmirror/distfiles/
echo "Done! Please upload ${TARBALL} manually to: " \
	"https://pantheon.corp.google.com/storage/browser/chromeos-localmirror/distfiles/?debugUI=DEVELOPERS"
echo "If this is based on the same Bionic HEAD of a previous tarball bump up _p0 to the latest step number."
