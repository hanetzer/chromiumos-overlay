# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="60338a8ef06d801b6d2e343dbb14697a16f85c1b"
CROS_WORKON_TREE="b7fe12e4acd4794cdd077253801aed32ec5b1c3e"
CROS_WORKON_PROJECT="chromiumos/third_party/daisydog"
CROS_WORKON_OUTOFTREE_BUILD="1"

inherit cros-constants cros-workon toolchain-funcs user

DESCRIPTION="Simple HW watchdog daemon"
HOMEPAGE="${CROS_GIT_HOST_URL}/${CROS_WORKON_PROJECT}"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE=""

src_prepare() {
	cros-workon_src_prepare
}

src_configure() {
	cros-workon_src_configure
	tc-export CC
}

_emake() {
	emake -C "$(cros-workon_get_build_dir)" \
		top_srcdir="${S}" -f "${S}"/Makefile "$@"
}

src_compile() {
	_emake
}

src_install() {
	_emake DESTDIR="${D}" install
}

pkg_preinst() {
	enewuser watchdog
	enewgroup watchdog
}
