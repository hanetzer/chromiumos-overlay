# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="743c1208d6b175899ef8e4b74c33dcb8fcbe85f2"

KEYWORDS="arm amd64 x86"

inherit cros-debug cros-workon toolchain-funcs

DESCRIPTION="Login manager for Chromium OS."
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
IUSE="test"

RDEPEND=">chromeos-base/chromeos-login-0.0.1-r75"
DEPEND="${RDEPEND}"

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
