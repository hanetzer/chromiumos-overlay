# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

KEYWORDS="amd64 x86 arm"

inherit toolchain-funcs cros-workon

DESCRIPTION="File system integrity image generator for Chromium OS."
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
IUSE="test valgrind splitdebug"

RDEPEND="chromeos-base/libchrome
	 chromeos-base/libchromeos
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
	emake OUT=${S}/build \
		SPLITDEBUG=$(use splitdebug && echo 1) verity || \
		die "failed to make verity"
}

src_test() {
	tc-export CXX
	tc-export CC
	tc-export OBJCOPY
	tc-export STRIP
	# TODO(wad) add a verbose use flag to change the MODE=
	emake \
		OUT=${S}/build \
		VALGRIND=$(use valgrind && echo 1) \
		MODE=opt \
		SPLITDEBUG=0 \
		tests || die "unit tests (with ${GTEST_ARGS}) failed!"
}

src_install() {
	# TODO: copy splitdebug output somewhere
	into /
	dobin "${S}/build/verity"
}
