# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="4ea62729ca42256312badb0ef76462ceda5e3ad4"

inherit toolchain-funcs

DESCRIPTION="Upstart init scripts for NFS on Chromium OS"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 arm x86"

DEPEND=""
RDEPEND="sys-apps/upstart"

src_install() {
	# Install our NFS configuration files.
	dodir /etc/init
	install --owner=root --group=root --mode=0644 \
		"${FILESDIR}"/*.conf "${D}/etc/init/"
}
