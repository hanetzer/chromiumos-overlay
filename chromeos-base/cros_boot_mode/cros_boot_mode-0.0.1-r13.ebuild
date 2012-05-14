# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="a3df396f95e6f5f91adaafb2d25c981bd6c650ef"
CROS_WORKON_TREE="b21faacf6a9940571ef122363c19a1ac02595b4b"

EAPI="4"
CROS_WORKON_PROJECT="chromiumos/platform/cros_boot_mode"

inherit toolchain-funcs cros-debug cros-workon

DESCRIPTION="Chrome OS platform boot mode utility"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="test valgrind"

RDEPEND="test? ( chromeos-base/libchrome:85268[cros-debug=] )"

# qemu use isn't reflected as it is copied into the target
# from the build host environment.
DEPEND="${RDEPEND}
	test? ( dev-cpp/gmock )
	test? ( dev-cpp/gtest )
	valgrind? ( dev-util/valgrind )"

src_compile() {
	tc-export CC CXX OBJCOPY PKG_CONFIG
	# TODO(wad) figure out what this means since the makefile handles this
	# decision already.
	cros-debug-add-NDEBUG

	emake OUT="${S}"/build \
		MODE=opt \
		SPLITDEBUG=0 STRIP=true all
}

src_test() {
	# TODO(wad) add a verbose use flag to change the MODE=
	emake \
		OUT="${S}"/build \
		VALGRIND=$(use valgrind && echo 1) \
		MODE=dbg \
		SPLITDEBUG=0 \
		tests
}

src_install() {
	into /
	dobin build/cros_boot_mode

	into /usr
	dolib.so build/libcros_boot_mode.so

	insinto /usr/include/cros_boot_mode
	doins \
		active_main_firmware.h \
		bootloader_type.h \
		boot_mode.h \
		developer_switch.h \
		helpers.h \
		platform_reader.h \
		platform_switch.h
}
