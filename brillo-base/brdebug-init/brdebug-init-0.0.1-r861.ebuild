# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="b21e123defee9d99cdc31a1f888a9d4f5cc5bf38"
CROS_WORKON_TREE="812b2880a8f63b1b0ca51cb7cf319ccd6944d92f"
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
