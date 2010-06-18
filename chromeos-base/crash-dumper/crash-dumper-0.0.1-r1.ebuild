# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit cros-workon

DESCRIPTION="Build chromeos crash handler"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="x86 arm"
IUSE="test"

RDEPEND="chromeos-base/google-breakpad"
DEPEND="${RDEPEND}"

src_compile() {
	tc-export CXX PKG_CONFIG
	emake libcrash.so || die "compile failed."
}

src_install() {
	into /usr
	dolib.so libcrash.so || die
}
