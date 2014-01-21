# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="582fdbad14957e3fc0f09bec6b728628d3b3abf6"
CROS_WORKON_TREE="ff3f08de2ac7e52c28556a4d7484b3fc861bcf43"
CROS_WORKON_PROJECT="chromiumos/platform/init"
CROS_WORKON_LOCALNAME="init"

inherit cros-workon

DESCRIPTION="Additional upstart jobs that will be installed on test images"
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"

RDEPEND="!!chromeos-base/factorytest-init"

src_install() {
	insinto /etc/init
	doins test-init/*.conf
}

