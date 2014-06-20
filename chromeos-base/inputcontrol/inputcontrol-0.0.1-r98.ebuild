# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT="15d146a4aab10e0f2db18e428e210ed67d3f0c5a"
CROS_WORKON_TREE="0ba4721e13d628fd667acff48ddba14b2f34d31a"
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
