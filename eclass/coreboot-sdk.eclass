# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# Check for EAPI 4+
case "${EAPI:-0}" in
4|5|6) ;;
*) die "unsupported EAPI (${EAPI}) in eclass (${ECLASS})" ;;
esac

COREBOOT_SDK_PREFIX=/opt/coreboot-sdk

COREBOOT_SDK_PREFIX_arm=${COREBOOT_SDK_PREFIX}/bin/arm-eabi-
COREBOOT_SDK_PREFIX_arm64=${COREBOOT_SDK_PREFIX}/bin/aarch64-elf-
COREBOOT_SDK_PREFIX_mips=${COREBOOT_SDK_PREFIX}/bin/mipsel-elf-
COREBOOT_SDK_PREFIX_nds32=${COREBOOT_SDK_PREFIX}/bin/nds32le-elf-
COREBOOT_SDK_PREFIX_x86_32=${COREBOOT_SDK_PREFIX}/bin/i386-elf-
COREBOOT_SDK_PREFIX_x86_64=${COREBOOT_SDK_PREFIX}/bin/x86_64-elf-
