# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="fba2ad0cde685d407b90311babe9caaf4e297c64"
CROS_WORKON_TREE="8aab728903a5de339777dace2aab54d398ebfaef"

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

