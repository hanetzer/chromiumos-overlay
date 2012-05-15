# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="e5627e7a2506fdd93f3b6edf48c76b68bfe75326"
CROS_WORKON_TREE="8f459ef16b87c47cb26400078c2ae353cb41455b"

EAPI="4"
CROS_WORKON_PROJECT="chromiumos/platform/dm-verity"

inherit toolchain-funcs cros-workon cros-au

DESCRIPTION="File system integrity image generator for Chromium OS"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE="32bit_au test valgrind splitdebug"

RDEPEND=""

# qemu use isn't reflected as it is copied into the target
# from the build host environment.
DEPEND="${RDEPEND}
	dev-cpp/gtest
	dev-cpp/gmock
	32bit_au? (
		dev-cpp/gtest32
		dev-cpp/gmock32
	)
	valgrind? ( dev-util/valgrind )"

src_compile() {
	use 32bit_au && board_setup_32bit_au_env
	tc-export AR CC CXX OBJCOPY STRIP
	emake \
		OUT="${S}/build" \
		WITH_CHROME=$(use test && echo 1 || echo 0) \
		SPLITDEBUG=0 STRIP=true \
		all
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
	dolib.a build/libdm-bht.a
	insinto /usr/include/verity
	doins dm-bht.h dm-bht-userspace.h
	insinto /usr/include/verity
	cd include
	doins -r linux asm asm-generic crypto
	cd ..
	into /
	dobin build/verity-static
	dosym verity-static bin/verity
}
