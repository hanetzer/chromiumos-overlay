# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="b9e38ebab242df98474f0b1afc13f52726f93d26"
CROS_WORKON_TREE="9381542076c052c4a449134b8b2f6b3a2adb6c70"
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

