# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT="627bbff32d8b94abd252989b4765c115b9f1d57a"
CROS_WORKON_TREE="9cbe5964364f5ee1a63ff0414345b68254e19242"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="smbprovider"

inherit cros-workon platform user

DESCRIPTION="Provides access to Samba file share"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/smbprovider/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="
	chromeos-base/libbrillo
	>=net-fs/samba-4.5.3-r6
	sys-apps/dbus
"

DEPEND="
	${RDEPEND}
	chromeos-base/protofiles:=
	chromeos-base/system_api
"

pkg_preinst() {
	enewuser "smbproviderd"
	enewgroup "smbproviderd"
}

src_install() {
	dosbin "${OUT}"/smbproviderd
	newbin smbproviderd-jailed.sh smbproviderd-jailed

	insinto /etc/dbus-1/system.d
	doins etc/dbus-1/org.chromium.SmbProvider.conf

	insinto /usr/share/dbus-1/system-services
	doins org.chromium.SmbProvider.service
}

platform_pkg_test() {
	local tests=(
		smbprovider_test
	)
	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done
}