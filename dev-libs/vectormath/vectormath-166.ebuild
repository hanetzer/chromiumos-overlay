# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

DESCRIPTION="Sony vector math library."
HOMEPAGE="http://www.bulletphysics.com/Bullet/phpBB2/viewforum.php?f=18"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE=""

src_unpack() {
	local vectormathlibrary="${CHROMEOS_ROOT}/src/third_party/vectormath/files/vectormathlibrary/"
	elog "Using vectormathlibrary: $vectormathlibrary"
	mkdir -p "${S}"
	cp -a "${vectormathlibrary}"/* "${S}" || die
}

src_install() {
	insinto /usr/include/vectormath/scalar/cpp
	doins "${S}/include/vectormath/scalar/cpp/mat_aos.h"
	doins "${S}/include/vectormath/scalar/cpp/quat_aos.h"
	doins "${S}/include/vectormath/scalar/cpp/vec_aos.h"
	doins "${S}/include/vectormath/scalar/cpp/vectormath_aos.h"
}
