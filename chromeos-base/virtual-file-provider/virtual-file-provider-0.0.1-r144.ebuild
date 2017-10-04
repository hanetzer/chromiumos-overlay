# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT="658357d16327762bc318675a8c272ee2c7a9c8c5"
CROS_WORKON_TREE="2a85bfe595dfa22be780c2801097429e025bad5a"
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
