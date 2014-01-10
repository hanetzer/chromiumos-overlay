# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="14dc7d9a860e7dffc18151434c0111482e109cfd"
CROS_WORKON_TREE="13ecf11776475d4565a9207981b050ae540f8f4a"
CROS_WORKON_PROJECT="chromiumos/platform/init"
CROS_WORKON_LOCALNAME="init"

inherit cros-workon

DESCRIPTION="Install the upstart job that launches the openssh-server."
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"

RDEPEND="!chromeos-base/chromeos-dev-init"

src_install() {
	insinto /etc/init
	doins openssh-server-init/*.conf
}
