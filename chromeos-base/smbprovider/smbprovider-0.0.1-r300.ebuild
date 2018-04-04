# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT="e456795c0641818a345caad05834efcb9b8f8132"
CROS_WORKON_TREE=("61b4b0c05e003fddaa705031945fece7f560c7d7" "a29ece684a5316265a6d51616eeb5ff266d5e78e")
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

	insinto /etc/dbus-1/system.d
	doins etc/dbus-1/org.chromium.SmbProvider.conf

	insinto /usr/share/dbus-1/system-services
	doins org.chromium.SmbProvider.service

	insinto /etc/init
	doins etc/init/smbproviderd.conf
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
