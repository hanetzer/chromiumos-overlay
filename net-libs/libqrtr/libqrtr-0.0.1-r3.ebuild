# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="5"
CROS_WORKON_COMMIT="d59deaca6fab17347716900e06088e6636ec105d"
CROS_WORKON_TREE="0868870cb1bec51baadc9a0b1bac1039f9d470e0"
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
