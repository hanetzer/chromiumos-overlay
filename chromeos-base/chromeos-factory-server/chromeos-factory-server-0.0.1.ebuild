# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

inherit user

DESCRIPTION="Ebuild which pulls in required packages for running Chromium OS factory server"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

# Dependencies common to all components in a CrOS factory server.
RDEPEND="
	dev-python/jsonrpclib
	net-misc/openssh
	net-misc/rsync
"

# Dependencies required for running factory_flow tool.
RDEPEND+="
	chromeos-base/autotest-server
	chromeos-base/chromeos-ec[utils]
	chromeos-base/chromite
	dev-embedded/openocd[ftdi]
	dev-libs/libusb[static-libs]
	net-ftp/tftp-hpa
	net-misc/dhcp
	sys-apps/flashrom[ft2232_spi]
"

# Dependencies required for running Umpire server.
RDEPEND+="
	dev-python/twisted-core
	dev-python/twisted-web
	www-servers/lighttpd
"

DEPEND=""

S=${WORKDIR}

pkg_preinst() {
	enewgroup goofy
	enewuser goofy
}

src_install() {
	insinto /etc/init
	doins "${FILESDIR}"/init/*.conf

	insinto /etc/sudoers.d
	echo "goofy ALL = NOPASSWD: ALL" >goofy-sudo
	insopts -m600
	doins goofy-sudo
}
