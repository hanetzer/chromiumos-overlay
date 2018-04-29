# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="b686935a5ff3fc8e2df55b2a04f99ef59ebc9ac7"
CROS_WORKON_TREE="d8af91a5c0bcf66c78d356c2f75e5dc58452dae5"
CROS_WORKON_PROJECT="chromiumos/third_party/kernel"
CROS_WORKON_LOCALNAME="kernel/v4.14"
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
