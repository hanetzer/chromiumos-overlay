# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

DESCRIPTION="A broad, well-tested, modular, and cross-browser JavaScript library"
HOMEPAGE="https://developers.google.com/closure/library/"
GIT_REV="2a79f2bc6b43115631fc6a1000e027c9d863a24d"
SRC_URI="https://github.com/google/${PN}/archive/${GIT_REV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"

S="${WORKDIR}"

src_install() {
	insinto /opt/closure-library
	doins -r closure-library-${GIT_REV}/*
}
