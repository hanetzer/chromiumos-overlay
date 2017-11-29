# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT="2b19559bce23df94e0572d5ac5d3c8e21d137905"
CROS_WORKON_TREE="1af145aac39554d884816b3438e14a0d2c5550aa"
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

platform_pkg_test() {
	platform_test "run" "${OUT}/virtual-file-provider_testrunner"
}
