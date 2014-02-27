# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="7558bdfb2d72bae24eebbc21bea4a2a9d42ada16"
CROS_WORKON_TREE="b4598b22d7fae37c42ea23bbda40473bffd4d84d"
CROS_WORKON_PROJECT="chromiumos/third_party/kernel-next"
CROS_WORKON_LOCALNAME="kernel-next"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-workon

HOMEPAGE="https://www.kernel.org/"
DESCRIPTION="Intel processor C-state and P-state reporting tool"

LICENSE="GPL-2"
SLOT=0
KEYWORDS="amd64 x86"
IUSE="-asan -clang"
REQUIRED_USE="asan? ( clang )"

domake() {
	emake -C tools/power/x86/turbostat \
		BUILD_OUTPUT="$(cros-workon_get_build_dir)" DESTDIR="${D}" \
		CROSS_COMPILE="${CHOST}-" "$@"
}

src_configure() {
	clang-setup-env
	cros-workon_src_configure
}

src_compile() {
	domake
}

src_install() {
	domake install
}
