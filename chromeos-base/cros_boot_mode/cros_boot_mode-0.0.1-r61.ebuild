# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="3afbc570a94db20feda5070400640b4c38669732"
CROS_WORKON_TREE="5590301c643b365ed9847e611e45abac6866ccf3"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_DESTDIR="${S}"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit toolchain-funcs cros-debug cros-workon

DESCRIPTION="Chrome OS platform boot mode utility"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="-asan -clang test valgrind"
REQUIRED_USE="asan? ( clang )"

LIBCHROME_VERS="271506"

RDEPEND="test? ( chromeos-base/libchrome:${LIBCHROME_VERS}[cros-debug=] )"

# qemu use isn't reflected as it is copied into the target
# from the build host environment.
DEPEND="${RDEPEND}
	test? ( dev-cpp/gmock )
	test? ( dev-cpp/gtest )
	valgrind? ( dev-util/valgrind )"

src_unpack() {
	cros-workon_src_unpack
	S+="/cros_boot_mode"
}

src_prepare() {
	cros-workon_src_prepare
}

src_configure() {
	clang-setup-env
	cros-workon_src_configure
}

src_compile() {
	cros-workon_src_compile
}

src_test() {
	# Needed for `cros_run_unit_tests`.
	cros-workon_src_test
}

src_install() {
	cros-workon_src_install
	into /
	dobin "${OUT}"/cros_boot_mode

	into /usr
	dolib.so "${OUT}"/libcros_boot_mode.so

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
