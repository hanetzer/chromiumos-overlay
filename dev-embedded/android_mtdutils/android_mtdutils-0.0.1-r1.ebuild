# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="c43b17f0adac1092e221ce6166ca8bc464090525"
CROS_WORKON_TREE="5645af494c0928f56b90922f58580b35295394b0"
CROS_WORKON_PROJECT="chromiumos/third_party/android_mtdutils"

inherit cros-workon toolchain-funcs

DESCRIPTION="Library to read from and write to an MTD device"
HOMEPAGE="https://android.googlesource.com/platform/bootable/recovery"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE=""

src_configure() {
	tc-export CC AR
	cros-workon_src_configure
}

src_compile() {
	cd mtdutils
	${CC} ${CPPFLAGS} ${CFLAGS} -o libmtdutils.o -c mtdutils.c || die
	${AR} rcs libmtdutils.a libmtdutils.o || die
}

src_install() {
	cd mtdutils
	dolib.a libmtdutils.a
	insinto /usr/include
	doins mtdutils.h
}
