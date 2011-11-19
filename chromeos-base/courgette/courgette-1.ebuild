# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="2"
CROS_WORKON_COMMIT="2a813cecf1b7357b1a2faf0f9e5bbb73ba9276b6"
CROS_WORKON_PROJECT="chromium/src/courgette"

inherit cros-workon cros-debug toolchain-funcs

DESCRIPTION="Chrome courgette/ library extracted for use on Chrome OS"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

RDEPEND=">=chromeos-base/libchrome-85268-r8"
DEPEND="${RDEPEND}"

src_prepare() {
  ln -s "${S}" "${WORKDIR}/courgette" &> /dev/null
  cp -p "${FILESDIR}/SConstruct" "${S}" || die
}

src_compile() {
	tc-export CC CXX AR RANLIB LD NM PKG_CONFIG
	cros-debug-add-NDEBUG
	export CCFLAGS="$CFLAGS"

	scons || die
}

src_install() {
	dolib.a libcourgette.a || die

	insinto /usr/include/courgette
	doins courgette.h || die
}
