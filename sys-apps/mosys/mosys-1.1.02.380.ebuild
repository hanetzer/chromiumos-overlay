# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="2"

inherit flag-o-matic toolchain-funcs

DESCRIPTION="Utility for obtaining various bits of low-level system info"
HOMEPAGE="http://mosys.googlecode.com/"
SRC_URI="http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/${PN}-${PV}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"
RDEPEND="sys-apps/util-linux"	# for libuuid

src_prepare() {
	epatch ${FILESDIR}/remove_KERNEL_def_1.1.02.380.patch
}

src_compile() {
	# Generate a default .config for our target architecture. This will
	# likely become more sophisticated as we broaden board support.
	einfo "using default configuration for $(tc-arch)"
	ARCH=$(tc-arch) make defconfig || die

	tc-export AR AS CC CXX LD NM STRIP OBJCOPY
	export LDFLAGS=$(raw-ldflags)
	emake || die
}

src_install() {
	dosbin mosys || die
}
