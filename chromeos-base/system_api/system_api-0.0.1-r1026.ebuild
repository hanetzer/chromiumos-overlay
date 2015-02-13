# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT=("2386b7b37426411cb40c5723aca24d61fde84020" "d2eb139b58ab885610685b199f9f3d05ec892082")
CROS_WORKON_TREE=("56d73eefa7abd3b9d7f2d978688a75f5bc6d4135" "476ba88dbce6b046d2d4d298338bc5ef39dcb2dd")
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

	local dir dirs=( cryptohome power_manager system_api )
	for dir in "${dirs[@]}"; do
		insinto /usr/include/"${dir}"/proto_bindings
		doins -r "${OUT}"/gen/include/"${dir}"/proto_bindings/*.h
	done
}
