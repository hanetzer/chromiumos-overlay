# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT="e0e3897964cff883ec663b3fd1fcd0b1d4674fc0"
CROS_WORKON_TREE="41033cba623e0430cd3b6dc2e37c4205d1c5db90"
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
