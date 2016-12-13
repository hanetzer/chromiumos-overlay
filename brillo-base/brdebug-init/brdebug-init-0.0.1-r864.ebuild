# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="920334706b3714df07ab9fb7c21753b234d3f753"
CROS_WORKON_TREE="c93111be0f94e00866821113dbd09b3634ac7b41"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_DESTDIR="${S}/platform2"

PLATFORM_SUBDIR="brdebug"

inherit cros-workon platform

DESCRIPTION="Install upstart for debug link"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	brillo-base/brdebug
	chromeos-base/chromeos-init
"

src_install() {
	insinto /etc/init
	doins init/brdebugd.conf
	doins init/setup-usb-link.conf
}
