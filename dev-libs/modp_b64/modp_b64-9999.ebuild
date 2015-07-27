# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_BLACKLIST=1
CROS_WORKON_DESTDIR="${S}"
CROS_WORKON_LOCALNAME="modp_b64"
CROS_WORKON_PROJECT="platform/external/modp_b64"
CROS_WORKON_REPO="https://android.googlesource.com"

inherit cros-workon

DESCRIPTION="Base64 encoder/decoder library."
HOMEPAGE="https://github.com/client9/stringencoders"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="~*"
IUSE=""

src_configure() {
	cros-workon_src_configure
}

src_compile() {
	cros-workon_src_compile
}

src_install() {
	newlib.a libmodpb64.pie.a libmodp_b64.a

	insinto /usr/include
	doins -r modp_b64
}
