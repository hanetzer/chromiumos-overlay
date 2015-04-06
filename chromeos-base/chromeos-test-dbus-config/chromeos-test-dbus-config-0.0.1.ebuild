# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

DESCRIPTION="Additional DBus configs that will be installed on test images"
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="leadership_election"

S="${WORKDIR}"

src_install() {
	insinto /etc/dbus-1/system.d
	#  Used to enable leaderd_Election to function correctly.
	use leadership_election && doins "${FILESDIR}"/leaderd-test-rules.conf
}
