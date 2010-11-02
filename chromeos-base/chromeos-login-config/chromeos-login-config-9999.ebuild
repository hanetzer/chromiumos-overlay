# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

KEYWORDS="~arm ~amd64 ~x86"

inherit cros-debug cros-workon toolchain-funcs

DESCRIPTION="Login manager for Chromium OS."
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
IUSE="test"

RDEPEND=""
DEPEND=""

CROS_WORKON_PROJECT="login_manager"
CROS_WORKON_LOCALNAME="${CROS_WORKON_PROJECT}"

src_compile() {
	true # Nothing to compile...
}

src_install() {
	dodir /etc
	insinto /etc
	doins default_proxy
}
