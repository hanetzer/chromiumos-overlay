# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

inherit eutils flag-o-matic toolchain-funcs

DESCRIPTION="Utility for obtaining various bits of low-level system info"
HOMEPAGE="http://mosys.googlecode.com/"
SRC_URI="http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/${PN}-${PV}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

RDEPEND="sys-apps/util-linux
	>=sys-apps/flashmap-0.3-r4"
DEPEND="${RDEPEND}"

src_prepare() {
	epatch "${FILESDIR}"/${PN}-1.2.03.476-ldflags.patch
}

src_compile() {
	# Generate a default .config for our target architecture. This will
	# likely become more sophisticated as we broaden board support.
	einfo "using default configuration for $(tc-arch)"
	ARCH=$(tc-arch) emake defconfig

	tc-export AR AS CC CXX LD NM STRIP OBJCOPY PKG_CONFIG
	export FMAP_LINKOPT="$(${PKG_CONFIG} --libs-only-l fmap)"
	append-ldflags "$(${PKG_CONFIG} --libs-only-L fmap)"
	export LDFLAGS="$(raw-ldflags)"
	append-flags "$(${PKG_CONFIG} --cflags fmap)"

	emake
}

src_install() {
	dosbin mosys
}
