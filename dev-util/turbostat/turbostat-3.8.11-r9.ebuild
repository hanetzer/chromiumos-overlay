# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="98d6fa96d08dbb08a2150dcd48a6b2a8773172e0"
CROS_WORKON_TREE="7223ac70621a5e856d579090a6d196acea7e2e58"
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
IUSE=""

domake() {
	emake -C tools/power/x86/turbostat \
		BUILD_OUTPUT="$(cros-workon_get_build_dir)" DESTDIR="${D}" \
		CROSS_COMPILE="${CHOST}-" "$@"
}

src_compile() {
	domake
}

src_install() {
	domake install
}
