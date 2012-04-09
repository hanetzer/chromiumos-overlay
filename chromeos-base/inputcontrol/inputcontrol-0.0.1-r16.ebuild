# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="ef34c493e25670e2bbc7a3e528bfd74fe59d5c5e"
CROS_WORKON_TREE="3697e6f6f3613b94bd3e5e75f2ea8211dbe12d8b"

EAPI="4"

CROS_WORKON_PROJECT="chromiumos/platform/inputcontrol"

inherit cros-workon

DESCRIPTION="A collection of utilities for configuring input devices"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

RDEPEND="x11-apps/xinput"
DEPEND="${RDEPEND}"

src_install() {
	emake DESTDIR="${D}" install || die "Install failed"
}

