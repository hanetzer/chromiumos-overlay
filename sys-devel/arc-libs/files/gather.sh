#!/bin/bash

### This script creates a tarball that contains libc / libcxx binaries and
### headers. Before running it, please modify the following 3 variables
### below. Then just run it from anywhere with no arguments.

# 1. Location of the android "mnc-dr-arc-dev" branch tree.
MNC_DR_ARC_DEV_TREE=${HOME}/android/mnc-dr-arc-dev

# 2. The dir to which the artifacts tarball (downloaded from go/a-b) was
# extracted.
ARTIFACTS_DIR=${HOME}/android/apple/target_files/

# 3. Destination directory.
TO_DIR=${HOME}/android/arc-libs-dir

### Do not change the following.

if [[ ! -d "$MNC_DR_ARC_DEV_TREE" ]] || \
    [[ ! -d "$ARTIFACTS_DIR" ]] ; then
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


runcmd mkdir -p "${TO_DIR}/usr/lib"
runcmd mkdir -p "${TO_DIR}/usr/include"
runcmd mkdir -p "${TO_DIR}/usr/include/c++/4.9"
runcmd mkdir -p "${TO_DIR}/usr/include/linux/asm"


### 1. Binaries.
BINARY_FILES="\
	libdl.so \
	libm.so \
	libc.so \
	libc++.so \
	libstdc++.so \
	libc_malloc_debug_leak.so \
	libc_malloc_debug_qemu.so \
	libpagemap.so \
	crtbegin_so.o \
	crtend_so.o"

ARTIFACTS_SYSTEM_DIR=${ARTIFACTS_DIR}/SYSTEM
for f in ${BINARY_FILES}
do
    F=$(find ${ARTIFACTS_SYSTEM_DIR} -name "$f" 2>/dev/null | wc -l)
    if [[ "$F" -ne "1" ]]; then
	echo "$f not found or there are more than 1 $f found, aborted."
	exit 1
    fi
    F=$(find ${ARTIFACTS_SYSTEM_DIR} -name "$f" 2>/dev/null)
    runcmd cp -p $F "${TO_DIR}/usr/lib"
done

for f in crtbegin_static.o crtbegin_dynamic.o crtend_android.o
do
    absolute_f=${MNC_DR_ARC_DEV_TREE}/out/target/product/cheets_arm/obj/lib/$f
    if [[ ! -e "${absolute_f}" ]]; then
	echo "${absolute_f} not found, perhaps you forgot to build it? Aborted."
	exit 1
    fi
    runcmd cp -p ${absolute_f} ${TO_DIR}/usr/lib
done


### 2. Bionic headers.
runcmd \
    cp -pPR ${MNC_DR_ARC_DEV_TREE}/bionic/libc/include/* ${TO_DIR}/usr/include


### 3. Libcxx headers.
CXX_HEADERS_DIR=${TO_DIR}/usr/include/c++/4.9
runcmd cp -pPR ${MNC_DR_ARC_DEV_TREE}/external/libcxx/include/* \
    ${CXX_HEADERS_DIR}


### 4.1 Linux headers.
for f in linux asm-generic drm misc mtd rdma scsi sound video xen
do
    runcmd cp -pPR ${MNC_DR_ARC_DEV_TREE}/bionic/libc/kernel/uapi/$f \
	${TO_DIR}/usr/include
done


### 4.2 Linux kernel assembly.
runcmd cp -pPR ${MNC_DR_ARC_DEV_TREE}/bionic/libc/kernel/uapi/asm-arm/* \
    ${TO_DIR}/usr/include/asm

### 5. Do the pack.
PACKET_VERSION=$(git --git-dir=${MNC_DR_ARC_DEV_TREE}/bionic/.git log \
    --pretty=%ci -1 | cut -f"1 2" -d" " | sed -e 's!-\| !.!g' -e 's!:!!g')
TARBALL=${TO_DIR}/../arc-libs-${PACKET_VERSION}.tar.gz
runcmd tar zcf "${TARBALL}" -C ${TO_DIR} .

### 6. Manually upload
echo Done! Please upload ${TARBALL} manually to: \
    https://pantheon.corp.google.com/storage/browser/chromeos-localmirror/distfiles/?debugUI=DEVELOPERS
