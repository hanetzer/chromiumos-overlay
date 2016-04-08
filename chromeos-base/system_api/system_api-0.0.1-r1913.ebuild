# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT=("ad8ac01d85f21564be8e029a43d4e462fb3637be" "4b936110e07abfa7b582e15af36d805bef25318b")
CROS_WORKON_TREE=("5bd946b415ecc6febbcc954e562810883c6fe112" "05dcafed31b4bd61182b542c2387d0c9011691f4")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_USE_VCSID=1
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
		cros-disks
		cryptohome
		debugd
		login_manager
		lorgnette
		permission_broker
		power_manager
		shill
		update_engine
	)
	for dir in "${dirs[@]}"; do
		insinto /usr/include/"${dir}"-client/"${dir}"
		doins dbus/"${dir}"/dbus-constants.h
	done

	dirs=( cryptohome power_manager system_api )
	for dir in "${dirs[@]}"; do
		insinto /usr/include/"${dir}"/proto_bindings
		doins -r "${OUT}"/gen/include/"${dir}"/proto_bindings/*.h
	done
}
