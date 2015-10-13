# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT=("20f5a8c6886cadf0fede0837848737e6d92bcde1" "039d6161819f994c9d243af782956fe38bc0a0f4")
CROS_WORKON_TREE=("93313e0c49ee71d3c9ffb426a4d236f716912afe" "43754566b7168fcd0807b6f02299e029222d314b")
CROS_WORKON_BLACKLIST=1
CROS_WORKON_LOCALNAME=("platform2" "aosp/system/connectivity/shill")
CROS_WORKON_PROJECT=("chromiumos/platform2" "platform/system/connectivity/shill")
CROS_WORKON_REPO=("https://chromium.googlesource.com" "https://android.googlesource.com")
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
