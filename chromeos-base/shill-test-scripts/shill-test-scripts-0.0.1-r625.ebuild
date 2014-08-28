# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="9a0ca1f34d469b70c5cf2d99c23f5795f62d5ce6"
CROS_WORKON_TREE="4afa058191e1f8b050f05859198f50f0939b7e84"
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
