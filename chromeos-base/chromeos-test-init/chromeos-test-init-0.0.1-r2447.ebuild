# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="dc0a207d7d643d73070767f65c1acf030aaaa162"
CROS_WORKON_TREE="5f68e7e6af6bc1bbac4e7f30825296c0b1c1ad47"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_DESTDIR="${S}"

inherit cros-workon

DESCRIPTION="Additional upstart jobs that will be installed on test images"
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="X"

src_unpack() {
	cros-workon_src_unpack
	S+="/init"
}

src_install() {
	insinto /etc/init
	doins upstart/test-init/*.conf
	dosbin upstart/test-init/job-filter

	insinto /usr/share/cros
	doins upstart/test-init/*_utils.sh

	use X || rm -f "${D}"/etc/init/vnc.conf
}

