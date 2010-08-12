# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

inherit cros-workon

EAPI=2

DESCRIPTION="Chrome OS Firmware"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="~arm ~x86"
IUSE=""

DEPEND="sys-apps/flashrom sys-apps/iotools"
RDEPEND=""

# ---------------------------------------------------------------------------
# CUSTOMIZATION SECTION

# Each OEM will have their own ebuild to overlay this file such that
# they can specify their own shellball generation instruction.

# It is suggested to put your firmware image files in "files/" folder
# and use "$FILESDIR" prefix to following path.

# Your BIOS firmware image file name.
# Example: BIOS_IMAGE="$FILESDIR/BIOS_0008.fd"
BIOS_IMAGE=""

# Your EC (embedded controller) firmware image file name.
# Example: EC_IMAGE="$FILESDIR/EC_0012.fd"
EC_IMAGE=""

# If you need a special version of flashrom tool, put file name here.
# Example: FLASHROM_BINARY="$FILESDIR/flashrom.private"
FLASHROM_BINARY=""

# If you need any additional resources in firmware update (ex,
# a customization script like "install_firmware_custom.sh"),
# put the filename of directory name here.
# Example: FW_EXTRA_DIST="$FILESDIR/mydist"
FW_EXTRA_DIST=""

# ---------------------------------------------------------------------------

CROS_WORKON_LOCALNAME="firmware"
CROS_WORKON_PROJECT="firmware"
INSTALL_DIR="/usr/sbin/${CROS_WORKON_LOCALNAME}"
UPDATE_SCRIPT="chromeos-firmwareupdate"

src_compile() {
  local image_cmd="" ext_cmd=""

  # prepare images
  if [ -n "$BIOS_IMAGE" ]; then
    image_cmd="$image_cmd -b $BIOS_IMAGE"
  fi
  if [ -n "$EC_IMAGE" ]; then
    image_cmd="$image_cmd -e $EC_IMAGE"
  fi

  # prepare extra commands
  if [ -n "$FLASHROM_BINARY" ]; then
    ext_cmd="$ext_cmd --flashrom $FLASHROM_BINARY"
  fi
  if [ -n "$FW_EXTRA_DIST" ]; then
    ext_cmd="$ext_cmd --extra $FW_EXTRA_DIST"
  fi

  # pack firmware update script!
  if [ -z "$image_cmd" ]; then
    # create an empty update script for the x86-generic case
    # (no need to update)
    einfo "building empty firmware update script"
    echo -n > ${UPDATE_SCRIPT}
  else
    # create a new script
    einfo "building firmware with images: $image_cmd $ext_cmd"
    "${WORKDIR}/${CROS_WORKON_LOCALNAME}"/pack_firmware.sh \
      -o ${UPDATE_SCRIPT} $image_cmd $ext_cmd \
      --tool_base="$ROOT/usr/sbin"
  fi

  chmod +x ${UPDATE_SCRIPT}
}

src_install() {
  dosbin $UPDATE_SCRIPT

  # following files are for SAFT
  for subdir in saft x86-generic
  do
    dstdir="${INSTALL_DIR}/${subdir}"
    dodir "${dstdir}"
    exeinto "${dstdir}"
    doexe "${WORKDIR}/${CROS_WORKON_LOCALNAME}/${subdir}"/*.{py,sh}
  done
}
