# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT="c2c14d3a3b4d6ebeffc45bc4a4c8feb557b920fe"
CROS_WORKON_TREE="11431265c39cb71c293227709fec55bbf4812e2a"
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