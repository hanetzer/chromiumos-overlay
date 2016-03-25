#!/bin/bash
#
# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
#
# This script creates a tarball that contains libc / libcxx binaries and
# headers. Before running it, please modify the following 4 variables
#   - MNC_DR_ARC_DEV_TREE
#   - ARTIFACTS_DIR_ARM
#   - ARTIFACTS_DIR_X86
#   - TO_DIR_BASE
# Then just run it from anywhere with no arguments.
# The constructed tarball will contain the sysroots under amd64 and arm (currently for 32-bit x86). It will
# be installed under /opt/android/${ARCH}.

set -e

# 1. Location of the android "mnc-dr-arc-dev" branch tree.
MNC_DR_ARC_DEV_TREE=${HOME}/android/mnc-dr-arc-dev

# ARCH names used in sysroot.
ARC_ARCH=('amd64' 'arm')

# ARCH names used in libc.
ARC_ARCH_LIBC=('x86' 'arm')

# ARCH names used in libm
ARC_ARCH_LIBM=('i387' 'arm')

# 2. The dir to which the artifacts tarball (downloaded from go/a-b) was
# extracted. Pick a -userdebug build.
# Now we support two platforms: arm and 32-bit x86.
ARTIFACTS_DIR_ARM=${HOME}/android/arm_target_files/
ARTIFACTS_DIR_X86=${HOME}/android/x86_target_files/
ARTIFACTS_DIR_ARRAY=(${ARTIFACTS_DIR_ARM} ${ARTIFACTS_DIR_X86})

# 3. Destination directory.
TO_DIR_BASE=${HOME}/android/arc-libs-dir

### Do not change the following.

if [[ ! -d "$MNC_DR_ARC_DEV_TREE" ]] || \
    [[ ! -d "$ARTIFACTS_DIR_ARM" ]] || \
    [[ ! -d "$ARTIFACTS_DIR_X86" ]] ; then
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
    if [[ -z "$dryrun" ]]; then
	echo ${cmdarray[@]}
	"${cmdarray[@]}"
    else
	echo "dryrun: ${cmdarray[@]}"
    fi
}


# Number of supported sysroots
len=$((${#ARC_ARCH[@]}-1))

# Setup the sysroot for each architecture.
for a in `seq 0 $len`
do
    arc_arch=${ARC_ARCH[$a]}
    arch=${ARC_ARCH_LIBC[$a]}

    arch_to_dir="${TO_DIR_BASE}/${arc_arch}"
    runcmd mkdir -p "${arch_to_dir}/usr/lib"
    runcmd mkdir -p "${arch_to_dir}/usr/include"
    runcmd mkdir -p "${arch_to_dir}/usr/include/c++/4.9"
    runcmd mkdir -p "${arch_to_dir}/usr/include/linux/asm"


    ### 1. Binaries.
    BINARY_FILES="\
	    libbinder.so \
	    libc.so \
	    libc++.so \
	    libcutils.so \
	    libdl.so \
	    libdrm.so \
	    libexpat.so \
	    libhardware.so \
	    liblog.so \
	    libm.so \
	    libstdc++.so \
	    libsync.so \
	    libui.so \
	    libutils.so \
	    libc_malloc_debug_leak.so \
	    libc_malloc_debug_qemu.so \
	    libpagemap.so \
	    crtbegin_so.o \
	    crtend_so.o"

    # x86 only
    if [[ "$arch" == "x86" ]]; then
	BINARY_FILES="$BINARY_FILES libgralloc_drm.so"
    fi

    artifacts_system_dir=${ARTIFACTS_DIR_ARRAY[$a]}/SYSTEM
    for f in ${BINARY_FILES}
    do
	F=$(find ${artifacts_system_dir} -name "$f" 2>/dev/null | wc -l)
	if [[ "$F" -ne "1" ]]; then
	    echo "$f not found or there are more than 1 $f found, aborted."
	    exit 1
	fi
	F=$(find ${artifacts_system_dir} -name "$f" 2>/dev/null)
	runcmd cp -p $F "${arch_to_dir}/usr/lib"
    done

    for f in crtbegin_static.o crtbegin_dynamic.o crtend_android.o
    do
	absolute_f=${MNC_DR_ARC_DEV_TREE}/prebuilts/ndk/9/platforms/android-21/arch-${arch}/usr/lib/$f
	if [[ ! -e "${absolute_f}" ]]; then
	    echo "${absolute_f} not found, perhaps you forgot to check it out?"\
                 " Aborted."
	    exit 1
	fi
	runcmd cp -p ${absolute_f} ${arch_to_dir}/usr/lib
    done


    ### 2. Bionic headers.
    for f in libc libm
    do
	runcmd \
	    cp -pPR ${MNC_DR_ARC_DEV_TREE}/bionic/$f/include/* \
		${arch_to_dir}/usr/include
    done


    ### 3. Libcxx headers.
    CXX_HEADERS_DIR=${arch_to_dir}/usr/include/c++/4.9
    runcmd cp -pPR ${MNC_DR_ARC_DEV_TREE}/external/libcxx/include/* \
	${CXX_HEADERS_DIR}


    ### 4.1 Linux headers.
    for f in linux asm-generic drm misc mtd rdma scsi sound video xen
    do
	runcmd cp -pPR ${MNC_DR_ARC_DEV_TREE}/bionic/libc/kernel/uapi/$f \
	    ${arch_to_dir}/usr/include
    done


    ### 4.2 Linux kernel assembly.
    runcmd cp -pPR ${MNC_DR_ARC_DEV_TREE}/bionic/libc/kernel/uapi/asm-${arch}/* \
	${arch_to_dir}/usr/include/asm


    ### 4.3 Other include directories
    INCLUDE_DIRS="\
	    bionic/libc/arch-${arch}/include/machine \
	    bionic/libm/include/${ARC_ARCH_LIBM[$a]}/machine \
	    frameworks/native/include/android \
	    frameworks/native/include/ui\
	    hardware/libhardware/include/hardware \
	    system/core/include/android \
	    system/core/include/cutils \
	    system/core/include/log \
	    system/core/include/system \
	    system/core/include/utils \
	    system/core/libsync/include/sync \
	    external/drm_gralloc \
	    external/libdrm"

    for f in ${INCLUDE_DIRS}
    do
	basename="$(basename $f)"
	todir="${arch_to_dir}/usr/include/$basename"
	mkdir -p $todir
	runcmd cp -pP ${MNC_DR_ARC_DEV_TREE}/$f/*.h $todir
    done

    # Fixup: do not ship private drm_gralloc include
    rm ${arch_to_dir}/usr/include/drm_gralloc/gralloc_drm_priv.h

    ### 4.4 More libdrm includes

    runcmd cp -pP ${MNC_DR_ARC_DEV_TREE}/external/libdrm/include/drm/*.h \
	"${arch_to_dir}/usr/include/libdrm"

    # x86 only
    if [[ "$arch" == "x86" ]]; then
	runcmd mkdir -p "${arch_to_dir}/usr/include/libdrm/intel"
	runcmd cp -pP ${MNC_DR_ARC_DEV_TREE}/external/libdrm/intel/*.h \
	    "${arch_to_dir}/usr/include/libdrm/intel"
    fi

    ### 4.5 Expat includes

    runcmd cp -pP ${MNC_DR_ARC_DEV_TREE}/external/expat/lib/expat*.h \
	"${arch_to_dir}/usr/include/"

    ### 4.6 OpenGL includes

    for f in EGL KHR
    do
	todir="${arch_to_dir}/usr/include/opengl/include/$f"
	mkdir -p $todir
	runcmd cp -pP \
	    ${MNC_DR_ARC_DEV_TREE}/frameworks/native/opengl/include/$f/*.h \
	    $todir
    done

done

### 5. Do the pack.
PACKET_VERSION=$(git --git-dir=${MNC_DR_ARC_DEV_TREE}/bionic/.git log \
    --pretty=%ci -1 | cut -f"1 2" -d" " | sed -e 's!-\| !.!g' -e 's!:!!g')
TARBALL=${TO_DIR_BASE}/../arc-libs-${PACKET_VERSION}.tar.gz
runcmd tar zcf "${TARBALL}" -C ${TO_DIR_BASE} .



### 6. Manually upload
echo Done! Please upload ${TARBALL} manually to: \
    https://pantheon.corp.google.com/storage/browser/chromeos-localmirror/distfiles/?debugUI=DEVELOPERS
