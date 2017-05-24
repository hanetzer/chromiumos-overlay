# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="c1264c555876d6d5553a45123b5fa401ded0a570"
CROS_WORKON_TREE="d82f80955d98e71be8ee1b0409509fb74cd9e8e6"
CROS_WORKON_PROJECT="chromiumos/platform/mosys"
CROS_WORKON_LOCALNAME="../platform/mosys"

inherit flag-o-matic toolchain-funcs cros-workon

DESCRIPTION="Utility for obtaining various bits of low-level system info"
HOMEPAGE="http://mosys.googlecode.com/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="static"

# We need util-linux for libuuid.
RDEPEND="sys-apps/util-linux
	>=sys-apps/flashmap-0.3-r4"
DEPEND="${RDEPEND}"

src_configure() {
	# Generate a default .config for our target architecture. This will
	# likely become more sophisticated as we broaden board support.
	einfo "using default configuration for $(tc-arch)"
	ARCH=$(tc-arch) emake defconfig

	tc-export AR CC LD PKG_CONFIG
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
}

src_install() {
	dosbin mosys
	dodoc README TODO
}
