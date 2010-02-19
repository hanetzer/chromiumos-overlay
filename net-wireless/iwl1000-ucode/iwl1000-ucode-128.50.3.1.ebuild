# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-wireless/iwl5150-ucode/iwl5150-ucode-8.24.2.2.ebuild,v 1.1 2009/06/29 12:30:41 hanno Exp $

# This ebuild was pulled from the gentoo bug tracker and is not yet available
# in the upstream gentoo repo.
# See http://bugs.gentoo.org/296352

MY_PN="iwlwifi-1000-ucode"

DESCRIPTION="Intel (R) Wireless WiFi Link 1000BGN ucode"
HOMEPAGE="http://intellinuxwireless.org/?p=iwlwifi"
SRC_URI="http://intellinuxwireless.org/iwlwifi/downloads/${MY_PN}-${PV}.tgz"

LICENSE="Intel"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RDEPEND=""

DEPEND="|| ( >=sys-fs/udev-096 >=sys-apps/hotplug-20040923 )"

S="${WORKDIR}/${MY_PN}-${PV}"

src_compile() {
  true;
}

src_install() {
  insinto /lib/firmware
  doins "${S}/iwlwifi-1000-3.ucode"

  dodoc README* || die "dodoc failed"
}
