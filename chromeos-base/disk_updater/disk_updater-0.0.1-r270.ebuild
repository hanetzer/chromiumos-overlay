# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="b5acc07710af5d168ee42675132a502fab60ef3d"
CROS_WORKON_TREE="7ae4033a4f1068a70c15927af4b8228f851a777b"
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
