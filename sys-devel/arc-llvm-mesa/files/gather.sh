#!/bin/bash
#
# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
#
# This script creates a tarball that contains LLVM binaries and
# headers. Before running it, please modify the following 3 variables if
# necessary:
#   - MNC_DR_ARC_DEV_TREE
#   - TO_DIR_BASE
#   - INCLUDE_LLVM_STATIC_LIBS
# Then just run it from anywhere with no arguments.
# The constructed tarball will contain the LLVM installation subdir. It will
# be installed under /opt/android/arc-llvm-mesa.


# Before running this script, the ARC dev tree must have built for x86 and LLVM
# components must have been enabled
# $ lunch cheets_x86-user
# Build libLLVM (as part of the complete build)
# $ FORCE_BUILD_LLVM_COMPONENTS=true m -j32
# Build llvm-config
# $ mmm external/llvm/tools/llvm-config/

set -e

### 1. Location of the android "mnc-dr-arc-dev" branch tree.
MNC_DR_ARC_DEV_TREE="${MNC_DR_ARC_DEV_TREE:-"${HOME}/android/mnc-dr-arc-dev"}"

### 2. Destination directory.
TO_DIR_BASE="${TO_DIR_BASE:-"${HOME}/android/arc-llvm-mesa"}"

### 3. Pick up static libraries or not.
# Those are used to link Mesa statically, e.g. for debugging. Disabled by
# default since they take up almost 1GB of disk space.
INCLUDE_LLVM_STATIC_LIBS="${INCLUDE_LLVM_STATIC_LIBS:-"no"}"


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

### 4. Setup destination directory.
runcmd mkdir -p "${TO_DIR_BASE}/lib"
runcmd mkdir -p "${TO_DIR_BASE}/lib64"
runcmd mkdir -p "${TO_DIR_BASE}/bin"
runcmd mkdir -p "${TO_DIR_BASE}/include"

LLVM_CONFIG="${MNC_DR_ARC_DEV_TREE}/out/host/linux-x86/bin/llvm-config"
LLVM_VERSION=`${LLVM_CONFIG} --version`

### 5. Copy files to destination directory.

# 5.1 Pick up static libraries.
if [ ${INCLUDE_LLVM_STATIC_LIBS} = "yes" ]; then
    # Find all files named libLLVM*.a in the device build output directory and
    # copy them to the destination directory.
    runcmd find "${MNC_DR_ARC_DEV_TREE}/out/target/product/cheets_x86/" \
        -name "libLLVM*.a" -print0 -exec cp -pP -t "${TO_DIR_BASE}/lib" {} +
fi

# 5.2 Copy the shared library.
runcmd cp -pP "${MNC_DR_ARC_DEV_TREE}/out/target/product/cheets_x86/system/lib/libLLVM.so" \
    "${TO_DIR_BASE}/lib"
# Mesa expects the library to be called libLLVM-X.y.so, create a symlink.
runcmd ln -rs "${TO_DIR_BASE}/lib/libLLVM.so" \
    "${TO_DIR_BASE}/lib/libLLVM-${LLVM_VERSION}.so"

# 5.3 Copy llvm-config. This is the host's version, ARC doesn't build the target
# version yet. Mesa's build only needs the compilation/link flags which are
# identical between the two.
runcmd cp -pP "${LLVM_CONFIG}" "${TO_DIR_BASE}/bin"
# llvm-config needs libc++.so
runcmd cp -pP "${MNC_DR_ARC_DEV_TREE}/out/host/linux-x86/lib64/libc++.so" \
    "${TO_DIR_BASE}/lib64"

# 5.4 Copy the header files.
runcmd cp -pP -r "${MNC_DR_ARC_DEV_TREE}/external/llvm/include/llvm" \
    "${TO_DIR_BASE}/include"
runcmd cp -pP -r "${MNC_DR_ARC_DEV_TREE}/external/llvm/include/llvm-c" \
    "${TO_DIR_BASE}/include"
# Replace the configuration header files with the checked-in version
runcmd rm -rf "${TO_DIR_BASE}/include/llvm/Config"
runcmd cp -pP -r  "${MNC_DR_ARC_DEV_TREE}/external/llvm/device/include/llvm/Config/" \
    "${TO_DIR_BASE}/include/llvm"
runcmd cp -pP "${MNC_DR_ARC_DEV_TREE}/external/llvm/include/llvm/Config/llvm-platform-config.h" \
    "${TO_DIR_BASE}/include/llvm/Config"

### 6. Do the pack.
PACKET_VERSION=$(git --git-dir=${MNC_DR_ARC_DEV_TREE}/external/llvm/.git log \
    --pretty=%ci -1 | cut -f"1 2" -d" " | sed -e 's!-\| !.!g' -e 's!:!!g')
TARBALL=${TO_DIR_BASE}/../arc-llvm-mesa-${PACKET_VERSION}_p0.tar.gz
runcmd tar zcf "${TARBALL}" -C ${TO_DIR_BASE} .

### 7. Manually upload
### Or you try this command: gsutil cp -a public-read arc-llvm-mesa-* gs://chromeos-localmirror/distfiles/
echo "Done! Please upload ${TARBALL} manually to: " \
     "https://pantheon.corp.google.com/storage/browser/chromeos-localmirror/distfiles/?debugUI=DEVELOPERS"
echo "If this is based on the same LLVM HEAD of a previous tarball bump up _p0 to the latest step number."

exit 0
