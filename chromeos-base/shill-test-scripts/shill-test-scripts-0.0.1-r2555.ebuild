# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT=("16e61e80f8e115146969a2116b125970d764c4a5" "1a8d3f4e25945ede4da3c629d2a6f1fcf76d0fdc")
CROS_WORKON_TREE=("b6e99fbe1c61ec6506cc75d8791d63c3029613d7" "71b19f7b68caabeed557c2eb4fb92cbc49461c9e")
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
