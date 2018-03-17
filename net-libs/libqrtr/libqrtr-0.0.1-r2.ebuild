# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="5"
CROS_WORKON_COMMIT="b6b84fd7af5d9c0603c411babfde49301e0a5541"
CROS_WORKON_TREE="6b23f9ae4cd4d8cdb2319b7d7591a9d9d25a30c2"
CROS_WORKON_PROJECT="chromiumos/third_party/libqrtr"

inherit autotools cros-workon

DESCRIPTION="QRTR userspace helper library"
HOMEPAGE="https://github.com/andersson/qrtr"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="-asan"

DEPEND="
	sys-kernel/linux-headers
	virtual/pkgconfig
"

src_configure() {
	asan-setup-env
}

src_test() {
	# TODO(ejcaruso): upstream some tests for this thing
	:
}
