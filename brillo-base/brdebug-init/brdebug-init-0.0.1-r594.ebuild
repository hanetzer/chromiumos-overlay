# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="e040c6b099f11f82a8cc9c1569d8217bbf9d7e76"
CROS_WORKON_TREE="6788d36d19df5c75ddb8f4108546e7dad271e877"
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
