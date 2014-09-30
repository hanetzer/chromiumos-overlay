# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

DESCRIPTION="Install the upstart job that launches the openssh-server."
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

S=${WORKDIR}

RDEPEND="
	chromeos-base/chromeos-sshd-init
	net-misc/openssh
	virtual/chromeos-firewall
"

src_install() {
	dosym /usr/share/chromeos-ssh-config/init/openssh-server.conf \
	      /etc/init/openssh-server.conf
}
