# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_PROJECT="chromiumos/platform/memento_softwareupdate"

inherit cros-workon toolchain-funcs

DESCRIPTION="Chrome OS Memento Updater"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE="-asan -clang"
REQUIRED_USE="asan? ( clang )"

DEPEND=""
RDEPEND="app-arch/gzip
	app-shells/bash
	dev-libs/openssl
	dev-util/shflags
	dev-util/xxd
	net-misc/wget
	sys-apps/coreutils
	sys-apps/util-linux"

src_configure() {
	clang-setup-env
	cros-workon_src_configure
}

src_compile() {
	emake \
		CXX="$(tc-getCXX)" \
		CCFLAGS="${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}"
}

src_install() {
	exeinto /opt/google/memento_updater
	doexe \
		find_omaha.sh \
		memento_updater.sh \
		memento_updater_logging.sh \
		ping_omaha.sh \
		software_update.sh \
		split_write
}
