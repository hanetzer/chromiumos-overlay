# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="93a146e7a6f9a8fb582cd6b8a1b961e85c4c9b97"
CROS_WORKON_TREE="214ddc1309d01f47c32e7d2607ff7cd4b68c678a"
CROS_WORKON_PROJECT="chromiumos/platform/shill"
CROS_WORKON_LOCALNAME="shill"

inherit cros-workon

DESCRIPTION="shill's test scripts"
HOMEPAGE="http://src.chromium.org"

LICENSE="BSD"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"
IUSE=""

DEPEND="!!chromeos-base/flimflam-test
	dev-lang/python
	dev-python/dbus-python
	dev-python/pygobject"

RDEPEND="${DEPEND}
	chromeos-base/shill
	net-dns/dnsmasq
	sys-apps/iproute2"

src_install() {
	exeinto /usr/lib/flimflam/test
	doexe test-scripts/*
}
