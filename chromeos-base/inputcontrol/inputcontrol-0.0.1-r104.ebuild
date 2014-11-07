# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT="06750300dd466c100ebec6046abcdfb565de8ae2"
CROS_WORKON_TREE="e0db7e8117fa6b0458783b604aac3af515b95d69"
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
