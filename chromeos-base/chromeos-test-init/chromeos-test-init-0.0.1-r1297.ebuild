# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="ee10690a0cfe4f8305858ba7b7e9c5c17a63de46"
CROS_WORKON_TREE="37883ee199570e78f6553ff81c19be5faab1bf75"
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
	doins test-init/*.conf
	dosbin test-init/job-filter

	use X || rm -f "${D}"/etc/init/vnc.conf
}

