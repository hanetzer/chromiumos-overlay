# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="ddd877885044b5e2b39da2e71e54cb804ffd84f9"
CROS_WORKON_TREE="c55d3e81999c6e8d2e106a08d7d90a1b18d0ea70"
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
IUSE="X"

RDEPEND="app-admin/sudo
	X? ( chromeos-base/salsa )
	chromeos-base/vboot_reference
	chromeos-base/workarounds
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

src_install() {
	dobin crosh crosh-{dev,usb}
	dobin network_diag
	insinto /usr/share/misc
	doins "${WORKDIR}"/inputrc.crosh
}
