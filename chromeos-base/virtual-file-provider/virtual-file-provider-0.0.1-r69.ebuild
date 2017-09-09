# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT="8a98e2aa8e9662f1c9da2371c92608b52e207824"
CROS_WORKON_TREE="85b05e56dde87905a3d6f39214b5c1b24d9491b6"
CROS_WORKON_INCREMENTAL_BUILD="1"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="virtual_file_provider"

inherit cros-workon platform user

DESCRIPTION="D-Bus service to provide virtual file"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/virtual_file_provider"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	chromeos-base/libbrillo
	sys-fs/fuse
	sys-libs/libcap
"

DEPEND="${RDEPEND}
	chromeos-base/system_api"

src_install() {
	dobin "${OUT}"/virtual-file-provider
	newbin virtual-file-provider-jailed.sh virtual-file-provider-jailed

	insinto /usr/share/virtual-file-provider
	doins "${OUT}"/rootfs.squashfs

	insinto /etc/dbus-1/system.d
	doins org.chromium.VirtualFileProvider.conf

	insinto /usr/share/dbus-1/system-services
	doins org.chromium.VirtualFileProvider.service
}

pkg_preinst() {
	enewuser "virtual-file-provider"
	enewgroup "virtual-file-provider"
}
