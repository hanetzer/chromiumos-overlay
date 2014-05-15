#!/bin/bash
# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# TODO(hungte) Move this script to cros_bundle_firmware or somewhere.

OBJDUMP="${CHOST}-objdump"
OBJCOPY="${CHOST}-objcopy"
ELFEDIT="${CHOST}-elfedit"

die() {
  echo "$*" 1>&2
  exit 1
}

_cbfstool() {
  set -- cbfstool "$@"; echo "$@"; "$@" || die "'$*' failed"
}

_objcopy() {
  set -- "${OBJCOPY}" "$@"; echo "$@"; "$@" ||
    die "'$*' failed"
}

create_legacy_boot_image() {
  local cbfs_file="$1"
  local elf_file="$2"
  local temp_folder="$3"
  local arch="$4"
  local bootblock="${temp_folder}/bootblock"

  # Look for RW_LEGACY in depthcharge/board/$board/fmap.dts for size.
  if [ "${arch}" = "arm" ]; then
    local cbfs_size=$((1 * 1024 * 1024))
  else
    local cbfs_size=$((2 * 1024 * 1024))
  fi

  # Create a dummy bootblock to make cbfstool happy
  truncate -s 64 "${bootblock}"
  _cbfstool "${cbfs_file}" create -s ${cbfs_size} -B "${bootblock}" \
    -m "${arch}"
  _cbfstool "${cbfs_file}" add-payload -f "$elf_file" -n payload -c lzma
}

merge_uboot() {
  local uboot="$1"
  local dtb="$2"
  local output="$3"
  local arch="$4"
  local uboot_info="$("${OBJDUMP}" -f "${uboot}")"
  local section_info="$("${OBJDUMP}" -h "${uboot}")"
  local format="$(echo "${uboot_info}" | grep "file format " |
                  sed 's/.*file format //')"
  local entry="$(echo "${uboot_info}" | grep "^start address " |
                 sed 's/^start address //')"
  # Assume base address is the VMA of first section.
  local base="0x$(echo "${section_info}" | grep '^  0 ' |
                  awk '{print $4}')"
  # Convert into binary and concatenate DTB data.
  _objcopy -O binary "${uboot}" "${output}"
  cat "${dtb}" >>"${output}" || die "Failed to append ${dtb}"
  # Build new ELF.
  _objcopy -B "${arch}" -I binary -O "${format}" \
    --change-section-address .data="${base}" \
    --set-start "${entry}" "${output}"
  "${ELFEDIT}" --output-type exec "${output}" ||
    die "Failed to change ELF type"
  # Set flags and construct program header (must done after elfedit)
  _objcopy --set-section-flags .data=contents,alloc,load,code "${output}"
}

main() {
  [ "$#" -eq 4 ] || die "Usage: $0 uboot dtb temp output"
  local uboot="$1"
  local dtb="$2"
  local temp_dir="$3"
  local output="$4"
  local merged="${temp_dir}/u-boot-dtb"

  # Determine U-Boot architecture.
  # GCC/BFD names: arm, i386, i386:x86-64.
  # CBFS names: arm, x86.
  local uboot_arch="$("${OBJDUMP}" -f "${uboot}" | grep '^architecture: ')"
  local bfd_arch="${uboot_arch#architecture: }"
  bfd_arch="${bfd_arch%%[,:]*}"
  local cbfs_arch=""
  case "${bfd_arch}" in
    "arm" )
      cbfs_arch="arm"
      ;;
    "i386" )
      cbfs_arch="x86"
      ;;
    * )
      die "Unknown architecture '${uboot_arch}': ${uboot}"
      ;;
  esac


  merge_uboot "$1" "$2" "${merged}" "${bfd_arch}"
  create_legacy_boot_image "${output}" "${merged}" "${temp_dir}" "${cbfs_arch}"
}

main "$@"
