# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="6e62cd8a5d1562aed537997ef414a56d169309b0"
CROS_WORKON_PROJECT="chromiumos/platform/debugd"

inherit cros-debug cros-workon toolchain-funcs

DESCRIPTION="Chrome OS debugging service."
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

RDEPEND="chromeos-base/chromeos-minijail"
DEPEND="${RDEPEND}"

CROS_WORKON_LOCALNAME=$(basename ${CROS_WORKON_PROJECT})

src_compile() {
	tc-export CC CXX AR RANLIB LD NM PKG_CONFIG OBJCOPY
	cros-debug-add-NDEBUG
	emake
}

src_test() {
	echo "Temporarily disabled..."
#	emake tests
}

src_install() {
	cd build-opt
	into /
	dosbin debugd
	dodir /debugd

	insinto /etc/dbus-1/system.d
	doins "${FILESDIR}/org.chromium.debugd.conf"
}
