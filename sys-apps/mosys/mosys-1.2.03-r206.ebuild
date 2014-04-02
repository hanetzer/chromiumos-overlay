# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="7d51ea897ad4867312c8ed50bfbfef12c4d18cfb"
CROS_WORKON_TREE="3aa079f3262b28bf8baaa0b43b81f565240ed6bd"
CROS_WORKON_PROJECT="chromiumos/platform/mosys"
CROS_WORKON_LOCALNAME="../platform/mosys"

inherit flag-o-matic toolchain-funcs cros-workon

DESCRIPTION="Utility for obtaining various bits of low-level system info"
HOMEPAGE="http://mosys.googlecode.com/"
LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="static"
RDEPEND="sys-apps/util-linux
         >=sys-apps/flashmap-0.3-r4"
DEPEND="${RDEPEND}"

src_compile() {
	# Generate a default .config for our target architecture. This will
	# likely become more sophisticated as we broaden board support.
	einfo "using default configuration for $(tc-arch)"
	ARCH=$(tc-arch) make defconfig || die

	tc-export AR AS CC CXX LD NM STRIP OBJCOPY PKG_CONFIG
	export FMAP_LINKOPT="$(${PKG_CONFIG} --libs-only-l fmap)"
	append-ldflags "$(${PKG_CONFIG} --libs-only-L fmap)"
	export LDFLAGS="$(raw-ldflags)"
	append-flags "$(${PKG_CONFIG} --cflags fmap)"
	export CFLAGS

	if use static; then
		#  We can't use append-ldflags because the build system doesn't
		#  handle LDFLAGS correctly:
		#  http://code.google.com/p/mosys/issues/detail?id=3
		append-flags "-static"
	fi

	emake || die
}

src_install() {
	dosbin mosys || die
}
