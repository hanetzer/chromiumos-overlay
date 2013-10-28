# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="20ca429fd7da0f2b1869f78f202204b98ae0a3c8"
CROS_WORKON_TREE="4fcd05880948307f0ac8a5a4a78139d1e9709ea0"
CROS_WORKON_PROJECT="chromiumos/platform/init"
CROS_WORKON_LOCALNAME="init"

inherit cros-workon

DESCRIPTION="Additional upstart jobs that will be installed on test images"
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"

src_install() {
	insinto /etc/init
	doins test-init/*.conf
}

