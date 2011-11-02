# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
CROS_WORKON_COMMIT="cc9f20f439396b7d45e94b8301edd95d33f26a46"
CROS_WORKON_PROJECT="chromiumos/third_party/libresample"

inherit cros-workon toolchain-funcs

DESCRIPTION="This is the resampling library. See README.txt for details."
HOMEPAGE=""
SRC_URI=""
LICENSE="LGPL"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

src_compile() {
	tc-getCC
	tc-getAR
	emake -j1 || die "emake failed"
}

src_install() {
	insinto /usr/lib
	insopts -m0755
	doins "${S}/libresample.a"
        insinto /usr/include/libresample
	doins "${S}/include/"*.h || die "include install failed"

}
