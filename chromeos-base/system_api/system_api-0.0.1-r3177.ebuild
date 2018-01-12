# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT=("bdce8d9c094d39e4a26277bdfa4ae4c1c1b9dfb4" "a9827d4872f488f8d35d4e1d221851f79239e400")
CROS_WORKON_TREE=("493f8afe7e7b936b53a0710c6b4c73c225f4a02b" "e4864b1fd9bfcabd0135318b0bc1ccab8359a212")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME=(
	"platform2"
	"platform/system_api"
)
CROS_WORKON_PROJECT=(
	"chromiumos/platform2"
	"chromiumos/platform/system_api"
)
CROS_WORKON_DESTDIR=(
	"${S}/platform2"
	"${S}/platform/system_api"
)

PLATFORM_SUBDIR="system_api"

inherit cros-workon toolchain-funcs platform

DESCRIPTION="Chrome OS system API (D-Bus service names, etc.)"
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="dev-libs/protobuf"


src_unpack() {
	local s="${S}"
	platform_src_unpack

	# The platform eclass will look for system_api in src/platform2.
	# This forces it to look in src/platform.
	S="${s}/platform/system_api"
}

src_install() {
	dolib.a "${OUT}"/libsystem_api*.a

	insinto /usr/"$(get_libdir)"/pkgconfig
	doins system_api.pc

	rm dbus/power_manager/OWNERS

	insinto /usr/include/chromeos
	doins -r dbus switches constants

	# Install the dbus-constants.h files in the respective daemons' client library
	# include directory. Users will need to include the corresponding client
	# library to access these files.
	local dir dirs=(
		apmanager
		biod
		cros-disks
		cryptohome
		debugd
		login_manager
		lorgnette
		permission_broker
		power_manager
		shill
		smbprovider
		update_engine
	)
	for dir in "${dirs[@]}"; do
		insinto /usr/include/"${dir}"-client/"${dir}"
		doins dbus/"${dir}"/dbus-constants.h
	done

	dirs=( authpolicy biod chaps cryptohome login_manager power_manager smbprovider system_api )
	for dir in "${dirs[@]}"; do
		insinto /usr/include/"${dir}"/proto_bindings
		doins -r "${OUT}"/gen/include/"${dir}"/proto_bindings/*.h
	done
}
