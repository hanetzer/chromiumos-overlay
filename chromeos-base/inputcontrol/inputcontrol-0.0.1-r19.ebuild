# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="8c3506432fad64ee1ebd96303562d6c9ad09a86b"
CROS_WORKON_TREE="6d10469654d683e6e771de7e2e2eea5b5bfedf7d"

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

