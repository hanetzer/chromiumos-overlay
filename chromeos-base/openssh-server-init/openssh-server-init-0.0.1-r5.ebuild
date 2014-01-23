# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="d8a69ad9f441fd6e939b4a2fa2be33432c510c4d"
CROS_WORKON_TREE="0a6ebe0b91194626de47802a4adc6083b617fb6c"
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
