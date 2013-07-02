# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="763df8647ed22caf6a160cedc3bb6f915a3a53dc"
CROS_WORKON_TREE="cdd0eab0aabe6c17eb8eee7feffd95980805ee22"
CROS_WORKON_PROJECT="chromiumos/platform/shill"
CROS_WORKON_LOCALNAME="shill"

inherit cros-workon

DESCRIPTION="shill's test scripts"
HOMEPAGE="http://src.chromium.org"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

RDEPEND="!!chromeos-base/flimflam-test
	chromeos-base/shill
	dev-lang/python
	dev-python/dbus-python
	dev-python/pygobject
	net-dns/dnsmasq
	sys-apps/iproute2"

DEPEND="${RDEPEND}"

src_install() {
	exeinto /usr/lib/flimflam/test
	doexe test-scripts/*
}
