# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="163a4be400f1ab4d5078ea376e193cdf1f79b875"
CROS_WORKON_TREE="b800d7589fab8fd6e3580fb7d0c00d5effbfe46f"
CROS_WORKON_PROJECT="chromiumos/third_party/kernel"
CROS_WORKON_LOCALNAME="kernel/v4.4"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-workon toolchain-funcs

HOMEPAGE="https://www.kernel.org/"
DESCRIPTION="Intel processor C-state and P-state reporting tool"

LICENSE="GPL-2"
SLOT=0
KEYWORDS="*"
IUSE="-asan"

domake() {
	emake -C tools/power/x86/turbostat \
		BUILD_OUTPUT="$(cros-workon_get_build_dir)" DESTDIR="${D}" \
		CC="$(tc-getCC)" "$@"
}

src_configure() {
	asan-setup-env
	cros-workon_src_configure
}

src_compile() {
	domake
}

src_install() {
	domake install
}
