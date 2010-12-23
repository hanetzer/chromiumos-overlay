# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="979bfd45c84f26c0c9fc2b21789bdf7259029f44"

KEYWORDS="amd64 x86 arm"

inherit toolchain-funcs cros-debug cros-workon

DESCRIPTION="File system integrity image generator for Chromium OS."
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
IUSE="test valgrind splitdebug"

RDEPEND="test? ( chromeos-base/libchrome )
	 test? ( chromeos-base/libchromeos )
	 dev-libs/openssl"

# qemu use isn't reflected as it is copied into the target
# from the build host environment.
DEPEND="${RDEPEND}
	test? ( dev-cpp/gmock )
	test? ( dev-cpp/gtest )
	valgrind? ( dev-util/valgrind )"

CROS_WORKON_PROJECT="dm-verity"

src_compile() {
	tc-export CXX
	tc-export CC
	tc-export OBJCOPY
	tc-export STRIP
	cros-debug-add-NDEBUG
	emake OUT=${S}/build \
		WITH_CHROME=$(use test && echo 1 || echo 0) \
		SPLITDEBUG=$(use splitdebug && echo 1) verity || \
		die "failed to make verity"
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
		MODE=opt \
		SPLITDEBUG=0 \
		WITH_CHROME=1 \
		tests || die "unit tests (with ${GTEST_ARGS}) failed!"
}

src_install() {
	# TODO: copy splitdebug output somewhere
	into /
	dobin "${S}/build/verity"
}
