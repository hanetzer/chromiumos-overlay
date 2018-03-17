# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT="41a5ab129ba7ccb7e9caf6c83a38d97a8c534906"
CROS_WORKON_TREE=("49286d8b2b9af4d6c1632fbe46a8778220775f6c" "2d6493cb9c0bc88a1c74cc6f83b0627fbc51dc7f")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk smbprovider"

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
