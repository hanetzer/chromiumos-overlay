# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT="fd81db4df50473408ca086cdbd4d887928548318"
CROS_WORKON_TREE="f2137bed76a01f0b5fb4f3a6dadf29213fc7a554"
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
