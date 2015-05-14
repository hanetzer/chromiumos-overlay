# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="3155078b553386ab101e780b3daa5973629783f9"
CROS_WORKON_TREE="95c7fec4617b6298035cd7c3fc067be42401fd67"
CROS_WORKON_PROJECT="chromiumos/platform/battery_updater"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-workon

DESCRIPTION="Battery Firmware Updater"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

src_install() {
	dosbin scripts/firmware-boot-update
}
