# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="27337a5d1759ff78cb6deff29aee944402e4d142"
CROS_WORKON_TREE="7477dbb1894236b25410dc213c01a0b07db9ee48"
CROS_WORKON_PROJECT="chromiumos/platform/shill"
CROS_WORKON_LOCALNAME="shill"

inherit cros-workon

DESCRIPTION="shill's test scripts"
HOMEPAGE="http://src.chromium.org"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="!!chromeos-base/flimflam-test
	dev-lang/python
	dev-python/dbus-python
	dev-python/pygobject"

RDEPEND="${DEPEND}
	chromeos-base/platform2
	net-dns/dnsmasq
	sys-apps/iproute2"

src_compile() {
	# We only install scripts here, so no need to compile.
	:
}

src_install() {
	exeinto /usr/lib/flimflam/test
	doexe test-scripts/*
}
