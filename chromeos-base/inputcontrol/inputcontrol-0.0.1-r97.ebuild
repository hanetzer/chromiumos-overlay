# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT="62e5e72b11fb48284db84effcff5b7d66654d4be"
CROS_WORKON_TREE="0be9dbaa22ffb6907bae63c2bab3650472ab5315"
CROS_WORKON_PROJECT="chromiumos/platform/inputcontrol"

inherit cros-workon

DESCRIPTION="A collection of utilities for configuring input devices"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="+X"

RDEPEND="
	app-arch/gzip
	X? ( x11-apps/xinput )
"
DEPEND="${RDEPEND}"

src_configure() {
	export HAVE_XINPUT=$(usex X 1 0)
	cros-workon_src_configure
}
