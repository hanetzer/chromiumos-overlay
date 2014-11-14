# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="b12cc58023b0f3a8c15c9b9db66608f0e4c63517"
CROS_WORKON_TREE="3a45c8b86a95e194a5b35cfe1fd9ec880370de01"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_DESTDIR="${S}"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-workon

DESCRIPTION="Root disk firmware updater"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND=""

RDEPEND="chromeos-base/chromeos-installer
	sys-apps/hdparm"

src_unpack() {
	cros-workon_src_unpack
	S+="/disk_updater"
}

src_test() {
	tests/chromeos-disk-firmware-test.sh || die "unittest failed"
}

src_install() {
	insinto "/etc/init"
	doins "scripts/chromeos-disk-firmware-update.conf"

	dosbin "scripts/chromeos-disk-firmware-update.sh"
}
