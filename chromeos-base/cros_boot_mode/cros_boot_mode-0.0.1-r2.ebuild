# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="f2cafd44f6f8e1ff30d0054d2842fdc419b53418"

KEYWORDS="amd64 arm x86"

inherit toolchain-funcs cros-debug cros-workon

DESCRIPTION="Chrome OS platform boot mode utility"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
IUSE="test valgrind splitdebug"

RDEPEND="test? ( chromeos-base/libchrome )"

# qemu use isn't reflected as it is copied into the target
# from the build host environment.
DEPEND="${RDEPEND}
	test? ( dev-cpp/gmock )
	test? ( dev-cpp/gtest )
	valgrind? ( dev-util/valgrind )"

CROS_WORKON_PROJECT="cros_boot_mode"

src_compile() {
	tc-export CXX
	tc-export CC
	tc-export OBJCOPY
	tc-export STRIP
	# TODO(wad) figure out what this means since the makefile handles this
	# decision already.
	cros-debug-add-NDEBUG
	# Include symbols since we use splitdebug later.
	emake OUT=${S}/build \
		MODE=opt \
		SPLITDEBUG=2 all || \
		die "failed to make cros_boot_mode"
}

src_test() {
	tc-export CXX
	tc-export CC
	tc-export OBJCOPY
	tc-export STRIP
	cros-debug-add-NDEBUG
	# TODO(wad) add a verbose use flag to change the MODE=
	emake \
		OUT=${S}/build \
		VALGRIND=$(use valgrind && echo 1) \
		MODE=dbg \
		SPLITDEBUG=0 \
		tests || die "unit tests (with ${GTEST_ARGS}) failed!"
}

src_install() {
	into /
	dobin "${S}/build/cros_boot_mode"

	into /usr
	insopts -m0644
	dolib.so "${S}/build/libcros_boot_mode.so"

	dodir "/usr/include/cros_boot_mode"
	insinto "/usr/include/cros_boot_mode"
	doins "${S}/active_main_firmware.h"
	doins "${S}/bootloader_type.h"
	doins "${S}/boot_mode.h"
	doins "${S}/developer_switch.h"
	doins "${S}/helpers.h"
	doins "${S}/platform_reader.h"
	doins "${S}/platform_switch.h"
}
