# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT=("1309823d57ee06e545501447069336c50740d47a" "2ba8d341801a8679c31f424cd101bc686dce3a10")
CROS_WORKON_TREE=("425730a194cc1d1a54c19d42d9d61d3d811635e7" "a3972d46d7a3b1ec09cd4fee24f50049c81d9054")
CROS_WORKON_LOCALNAME=("platform2" "aosp/system/connectivity/shill")
CROS_WORKON_PROJECT=("chromiumos/platform2" "aosp/platform/system/connectivity/shill")
CROS_WORKON_DESTDIR=("${S}/platform2" "${S}/platform2/shill")

inherit cros-workon

DESCRIPTION="shill's test scripts"
HOMEPAGE="http://src.chromium.org"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="!!chromeos-base/flimflam-test
	dev-lang/python
	dev-python/dbus-python
	dev-python/pygobject"

RDEPEND="${DEPEND}
	chromeos-base/shill
	net-dns/dnsmasq
	sys-apps/iproute2"

src_unpack() {
	cros-workon_src_unpack
	S+="/platform2/shill"
}

src_compile() {
	# We only install scripts here, so no need to compile.
	:
}

src_install() {
	exeinto /usr/lib/flimflam/test
	doexe test-scripts/*
}