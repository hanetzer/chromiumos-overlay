# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="844a0ca2d7e8f34bd09bc625abc71f5afb261e49"
CROS_WORKON_TREE="7e5feb5ece5e513585c8114f3a94efa8468d709b"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_DESTDIR="${S}"

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

src_unpack() {
  cros-workon_src_unpack
  S+="/shill"
}

src_compile() {
	# We only install scripts here, so no need to compile.
	:
}

src_install() {
	exeinto /usr/lib/flimflam/test
	doexe test-scripts/*
}
