# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="71df83e4c4426b9da657c4c11951d8882fb4713d"
CROS_WORKON_TREE="48ef0c1059d9bb333092750309d9e99dba9a6a24"
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
