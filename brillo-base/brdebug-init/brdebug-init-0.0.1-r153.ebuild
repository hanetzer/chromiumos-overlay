# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="4968830b913f845d3b6edd110c8f5e9bfe86f798"
CROS_WORKON_TREE="a9b49ecbdbdac080be258949a254ef10c89dfa93"
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
