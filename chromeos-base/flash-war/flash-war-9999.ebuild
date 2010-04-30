# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.  Use of this
# source code is governed by a BSD-style license that can be found in the
# LICENSE file.

EAPI="2"

DESCRIPTION="A workaround for flash crashes"

LICENSE="BSD"
SLOT="0"
KEYWORDS="arm x86"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}"

src_install() {
  dodir /etc/skel/.mozilla/firefox || die
  insinto /etc/skel/.mozilla/firefox || die
  doins "${FILESDIR}"/profiles.ini || die
}
