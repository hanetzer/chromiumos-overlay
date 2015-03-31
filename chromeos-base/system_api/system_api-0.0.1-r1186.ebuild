# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT=("f4b0b1aab38f38ffd93f5db7efa4f6b13f732ebe" "aea834300e75d5c64383be1050d9eec010a12059")
CROS_WORKON_TREE=("65f8029159e4776e12a30180094f40194865250e" "d90ea025e45e8be2663673827d73dfb8b8d6e9e5")
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

	local dir dirs=( cryptohome power_manager system_api )
	for dir in "${dirs[@]}"; do
		insinto /usr/include/"${dir}"/proto_bindings
		doins -r "${OUT}"/gen/include/"${dir}"/proto_bindings/*.h
	done
}
