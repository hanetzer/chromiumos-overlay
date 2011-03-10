# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="15a6ce315e19a63aeef573ce8d44c3ceb718eb7e"

inherit toolchain-funcs cros-workon

DESCRIPTION="Multitouch Xorg Xinput driver."
HOMEPAGE="http://bitmath.org/code/multitouch/"
CROS_WORKON_LOCALNAME="multitouch"
LICENSE="GPL"
SLOT="0"
IUSE=""
KEYWORDS="arm x86"

RDEPEND="x11-base/xorg-server
	 x11-libs/mtdev
	 x11-libs/pixman"
DEPEND="${RDEPEND}"

src_compile() {
	tc-export CC CXX AR RANLIB LD NM

	export CCFLAGS="$CFLAGS"
	CFLAGS="${CFLAGS} -I${SYSROOT}/usr/include/pixman-1"

	emake || die "compile failed"
}

src_install() {
	insinto /usr/lib/xorg/modules/input
	doins obj/multitouch.so
}
