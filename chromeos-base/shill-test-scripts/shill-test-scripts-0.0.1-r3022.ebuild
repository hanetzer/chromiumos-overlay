# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT=("1ca78ecc9ba0b7145c9b9723b27b38bb9bb14787" "aabff3f5d14198c3884580043c066c186a15f794")
CROS_WORKON_TREE=("a475b90c5dec2a30221be596f598e2e8d0ba2fdc" "6e4882d72cc7f38f190e4552deb2093ad08b6530")
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
