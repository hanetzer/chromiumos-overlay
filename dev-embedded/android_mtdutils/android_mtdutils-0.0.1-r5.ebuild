# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="9bcfc3ee238f16925e9aaa4573129784ebb397e7"
CROS_WORKON_TREE="e7691f21c00d4f035d0e0cc535e4b3d9e0e6b34e"
CROS_WORKON_PROJECT="chromiumos/third_party/android_mtdutils"

inherit cros-workon flag-o-matic toolchain-funcs

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
	append-cppflags -D_GNU_SOURCE
	append-lfs-flags
	${CC} ${CPPFLAGS} ${CFLAGS} -o libmtdutils.o -c mtdutils.c || die
	${AR} rcs libmtdutils.a libmtdutils.o || die
}

src_install() {
	cd mtdutils
	dolib.a libmtdutils.a
	insinto /usr/include
	doins mtdutils.h
}
