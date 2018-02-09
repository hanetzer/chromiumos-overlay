# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="42673c8e89e0e8bcf848eccff16f6b454d087646"
CROS_WORKON_TREE="444cc94c82f80a12e2f78d985c6a5d35e4eda33a"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_DESTDIR="${S}"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-workon

DESCRIPTION="Chrome OS command-line shell"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND="app-admin/sudo
	chromeos-base/vboot_reference
	net-misc/iputils
	net-misc/openssh
	net-wireless/iw
	sys-apps/net-tools
"
DEPEND=""

src_unpack() {
	cros-workon_src_unpack
	S+="/crosh"
}

src_compile() {
	# File order is important here.
	sed \
		-e '/^#/d' \
		-e '/^$/d' \
		inputrc.safe inputrc.extra \
		> "${WORKDIR}"/inputrc.crosh || die
}

src_test() {
	./run_tests.sh || die
}

src_install() {
	dobin crosh
	dobin network_diag
	local d="/usr/share/crosh"
	insinto "${d}/dev.d"
	doins dev.d/*.sh
	insinto "${d}/removable.d"
	doins removable.d/*.sh
	insinto "${d}"
	doins "${WORKDIR}"/inputrc.crosh
}
