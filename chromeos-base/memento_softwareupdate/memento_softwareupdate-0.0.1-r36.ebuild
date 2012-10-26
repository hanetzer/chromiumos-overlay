# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT=45887888530cd7e54c1c13c58d9df60a05a370b9
CROS_WORKON_TREE="c1b5172277b6864c0d58399baf155b7f42578c93"

EAPI="4"
CROS_WORKON_PROJECT="chromiumos/platform/memento_softwareupdate"

inherit cros-workon toolchain-funcs

DESCRIPTION="Chrome OS Memento Updater"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

DEPEND=""
RDEPEND="app-arch/gzip
	app-shells/bash
	dev-libs/openssl
	dev-util/shflags
	dev-util/xxd
	net-misc/wget
	sys-apps/coreutils
	sys-apps/util-linux"

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
