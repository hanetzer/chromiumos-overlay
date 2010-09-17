# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

inherit cros-workon

EAPI=2
CROS_WORKON_COMMIT="b714569b30d426d3e2edc08ba2555cbb735d9d4b"

DESCRIPTION="Chrome OS Firmware"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="arm x86"
IUSE=""

DEPEND="x86? (
    chromeos-base/vboot_reference
    sys-apps/flashrom
    sys-apps/iotools
    sys-apps/mosys )"
RDEPEND=""

CROS_WORKON_LOCALNAME="firmware"
CROS_WORKON_PROJECT="firmware"

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

# Change this to 1 if you REALLY want to update firmware whenever system invokes
# chromeos-postinst (for installation, recovery, and auto updates).
IS_FORCE_UPDATE=0

# If you need a special version of flashrom tool, put file name here.
# Example: FLASHROM_BINARY="$FILESDIR/flashrom.private"
FLASHROM_BINARY=""

# If you need any additional resources in firmware update (ex,
# a customization script like "install_firmware_custom.sh"),
# put the filename of directory name here.
# Example: FW_EXTRA_DIST="$FILESDIR/mydist"
FW_EXTRA_DIST=""

# ---------------------------------------------------------------------------

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
    einfo "Building empty firmware update script"
    echo -n > ${UPDATE_SCRIPT}
  else
    # create a new script
    einfo "Building firmware with images: $image_cmd $ext_cmd"
    "${WORKDIR}/${CROS_WORKON_LOCALNAME}"/pack_firmware.sh \
      -o ${UPDATE_SCRIPT} $image_cmd $ext_cmd \
      --tool_base="$ROOT/usr/sbin" || die "cannot pack firmware"
  fi

  chmod +x ${UPDATE_SCRIPT}
}

src_install() {
  # install the main updater program
  dosbin $UPDATE_SCRIPT || die "failed to install update script"

  # install the "force firmware update" tag
  if [ "$IS_FORCE_UPDATE" -eq "1" ]; then
    einfo " *** ENABLED A FORCED FIRMWARE UPDATE *** "
    test -s "$UPDATE_SCRIPT" || einfo " WARNING: USING EMPTY FIRMWARE UPDATE."
    insinto /root
    newins $FILESDIR/dot.force_update_firmware .force_update_firmware \
      || die "cannot create tag for forced firmware update"
  fi

  # Install saft code
  dstdir="/usr/sbin/${CROS_WORKON_LOCALNAME}/saft"
  dodir "${dstdir}"
  exeinto "${dstdir}"
  doexe saft/*.{py,sh}
}
