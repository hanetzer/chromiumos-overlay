# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="aab2759cb2a7689bf9248a5fb4a1f1be55bf9121"
CROS_WORKON_TREE="b80d5f3f9b6bd7a69ededafd0939422d0def1647"
CROS_WORKON_PROJECT="chromiumos/platform/rollog"
CROS_WORKON_LOCALNAME="../platform/rollog"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-workon

DESCRIPTION="Utility for implementing rolling logs for bug regression"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

src_prepare() {
	cros-workon_src_prepare
}

src_configure() {
	cros-workon_src_configure
}

src_compile() {
	cros-workon_src_compile
}

src_install() {
	cros-workon_src_install
	dobin "${OUT}"/rollog
}
