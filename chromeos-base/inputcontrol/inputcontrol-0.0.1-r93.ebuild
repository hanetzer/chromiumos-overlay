# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT="0fd600ecbefe664a302b84f8a568129edae3ad72"
CROS_WORKON_TREE="63a051ac0677ac6843c3dc6aef7b8dc7ff056e17"
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
