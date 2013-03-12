# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="aba893217c9cf1dd0d39c4dee89a23d3b1a3f4c1"
CROS_WORKON_TREE="4f0b19f0d188fbabd7825bc33874526d8baeb4d1"
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
