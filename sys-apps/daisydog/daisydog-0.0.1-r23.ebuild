# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="96d9e30fdfb7ab8b0cdc44228359dd0c08d59946"
CROS_WORKON_TREE="3ff9b64128ea344bf5e055d07cb5a47a6fc7cc09"
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
