# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="de3f55fcdbe4636f5cc1fe40c44a96df7e4b9460"
CROS_WORKON_PROJECT="chromiumos/platform/dm-verity"

inherit toolchain-funcs cros-debug cros-workon

DESCRIPTION="File system integrity image generator for Chromium OS"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE="test valgrind splitdebug"

RDEPEND="test? ( chromeos-base/libchrome:0 )
	 dev-libs/openssl"

# qemu use isn't reflected as it is copied into the target
# from the build host environment.
DEPEND="${RDEPEND}
	test? ( dev-cpp/gmock )
	test? ( dev-cpp/gtest )
	valgrind? ( dev-util/valgrind )"

src_compile() {
	tc-export AR CC CXX OBJCOPY STRIP
	cros-debug-add-NDEBUG
	emake \
		OUT="${S}/build" \
		WITH_CHROME=$(use test && echo 1 || echo 0) \
		SPLITDEBUG=0 STRIP=true \
		verity
}

src_test() {
	# TODO(wad) add a verbose use flag to change the MODE=
	emake \
		OUT="${S}/build" \
		VALGRIND=$(use valgrind && echo 1) \
		MODE=opt \
		SPLITDEBUG=0 \
		WITH_CHROME=1 \
		tests
}

src_install() {
	into /
	dobin build/verity
}
