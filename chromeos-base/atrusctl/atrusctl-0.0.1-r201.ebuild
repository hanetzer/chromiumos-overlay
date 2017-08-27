# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT=("579e25071e6920f30d61c66b17f5ac4706b37037" "00e0e3814aa0e82c2e50592e0d3f737902b17e26")
CROS_WORKON_TREE=("a729dc09e0796c35a52e0341e9d870f40c070b54" "bee8cfe107aeeb20279e08cfc892e75b046f7600")
CROS_WORKON_LOCALNAME=("platform2" "third_party/atrusctl")
CROS_WORKON_PROJECT=("chromiumos/platform2" "chromiumos/third_party/atrusctl")
CROS_WORKON_DESTDIR=("${S}/platform2" "${S}/third_party/atrusctl")
CROS_WORKON_INCREMENTAL_BUILD=1

PLATFORM_SUBDIR="atrusctl"

inherit cros-workon platform udev user

DESCRIPTION="CrOS daemon for the Atrus speakerphone"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/third_party/atrusctl/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

DEPEND="
	chromeos-base/libbrillo
	chromeos-base/libchrome
	virtual/libusb:1
	virtual/libudev:0=
"
RDEPEND="
	${DEPEND}
	!sys-apps/atrusctl
"

src_unpack() {
	local s="${S}"
	platform_src_unpack
	S="${s}/third_party/atrusctl"
}

src_install() {
	dosbin "${OUT}/atrusd"

	insinto /etc/rsyslog.d
	newins conf/rsyslog-atrus.conf atrus.conf

	udev_newrules conf/udev-atrus.rules 99-atrus.rules

	insinto /etc/init
	doins init/atrusd.conf
}

pkg_preinst() {
	enewuser atrus
	enewgroup atrus
}
