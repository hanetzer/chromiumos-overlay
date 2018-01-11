# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT="47bd326577890c152e9c58ddbb4371633f83b93e"
CROS_WORKON_TREE="17fdf536c56db2e2a30850780cf0efb9c5810bde"
CROS_WORKON_INCREMENTAL_BUILD="1"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="arc/mount-passthrough"
PLATFORM_GYP_FILE="mount-passthrough.gyp"

inherit cros-workon platform

DESCRIPTION="Mounts the specified directory with different owner UID and GID"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/arc/mount-passthrough"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND="sys-fs/fuse
	sys-libs/libcap"

DEPEND="${RDEPEND}"

src_install() {
	dobin "${OUT}"/mount-passthrough
	dobin mount-passthrough-jailed

	insinto /usr/share/mount-passthrough
	doins "${OUT}"/rootfs.squashfs
}
