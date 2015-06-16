# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="0680a2d0c4cec58f8163fe115de80cff8852fd8b"
CROS_WORKON_TREE="fa13d9f82563538210d7951d63a28f23dcb7a60b"
CROS_WORKON_PROJECT="chromium/deps/libmtp"
CROS_WORKON_LOCALNAME="../../chromium/src/third_party/libmtp"

inherit autotools cros-workon

DESCRIPTION="An implementation of Microsoft's Media Transfer Protocol (MTP)."
HOMEPAGE="http://libmtp.sourceforge.net/"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="*"
IUSE="-asan -clang +crypt doc examples static-libs"
REQUIRED_USE="asan? ( clang )"

RDEPEND="virtual/libusb:1
	crypt? ( dev-libs/libgcrypt )"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	doc? ( app-doc/doxygen )"

DOCS="AUTHORS ChangeLog README TODO"

src_prepare() {
	if [[ ${PV} == *9999* ]]; then
		touch config.rpath # This is from upstream autogen.sh
		eautoreconf
	fi
}

src_configure() {
	clang-setup-env
	cros-workon_src_configure \
		$(use_enable static-libs static) \
		$(use_enable doc doxygen) \
		$(use_enable crypt mtpz)
}

src_install() {
	default
	find "${ED}" -name '*.la' -exec rm -f {} +

	if use examples; then
		docinto examples
		dodoc examples/*.{c,h,sh}
	fi
}
