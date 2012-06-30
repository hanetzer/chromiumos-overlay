# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_PROJECT="chromiumos/platform/rollog"
CROS_WORKON_LOCALNAME="../platform/rollog"

inherit flag-o-matic toolchain-funcs cros-workon

DESCRIPTION="Utility for implementing rolling logs for bug regression"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE="static"

src_compile() {
	tc-export CC
	export FMAP_LINKOPT="$(${PKG_CONFIG} --libs-only-l fmap)"
	append-ldflags "$(${PKG_CONFIG} --libs-only-L fmap)"
	export LDFLAGS="$(raw-ldflags)"
	append-flags "$(${PKG_CONFIG} --cflags fmap)"
	export CFLAGS

	use static && append-ldflags -static

	emake
}

src_install() {
	dobin rollog
}
