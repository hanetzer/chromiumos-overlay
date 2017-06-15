# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT=("01c3c6e8007f62df0d6371b71dacce1c035acb74" "b7987d6263aed49ab08a3d841dd882604f8347a7")
CROS_WORKON_TREE=("5f14f98881fda51a945c8d274d29159a7077a6fb" "c147d47fad097066bf3e065905db1d20bcf026ec")
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
}

pkg_preinst() {
	enewuser atrus
	enewgroup atrus
}
