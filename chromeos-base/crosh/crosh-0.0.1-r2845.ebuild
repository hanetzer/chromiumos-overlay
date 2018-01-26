# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="8ac0f2ce0b8c086f0971dcbbe74fa30dca959af2"
CROS_WORKON_TREE="fd5d3a1423553ddb717b82e6b662de678c2e81dd"
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
