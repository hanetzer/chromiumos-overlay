# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

CROS_WORKON_COMMIT="abf933e3f7bc52f8ff080a904c7b17ebbff7053b"
CROS_WORKON_TREE=("61b4b0c05e003fddaa705031945fece7f560c7d7" "ff3422de95961e04145b1ca49f8ac571e9fa6fda")
CROS_WORKON_INCREMENTAL_BUILD="1"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk arc/sdcard"

PLATFORM_SUBDIR="arc/sdcard"
PLATFORM_GYP_FILE="sdcard.gyp"

inherit cros-workon platform

DESCRIPTION="Container to run Android's sdcard daemon."
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/arc/sdcard"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

CONTAINER_DIR="/opt/google/containers/arc-sdcard"

src_install() {
	insinto /etc/init
	doins arc-sdcard.conf

	insinto "${CONTAINER_DIR}"
	doins "${OUT}"/rootfs.squashfs

	# Keep the parent directory of mountpoints inaccessible from non-root
	# users because mountpoints themselves are often world-readable but we
	# do not want to expose them.
	# container-root is where the root filesystem of the container in which
	# arc-obb-mounter daemon runs is mounted.
	diropts --mode=0700 --owner=root --group=root
	keepdir "${CONTAINER_DIR}"/mountpoints/
	keepdir "${CONTAINER_DIR}"/mountpoints/container-root
}
