# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="1ee8f85b72bfe48fe895b1285111a37ed7aae950"
CROS_WORKON_TREE="4c163d3392320fd8452b3aa5262d7979e55e7869"
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
