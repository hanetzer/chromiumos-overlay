# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="599fccb17f675dca6a3a14b347b765de482908ea"
CROS_WORKON_TREE="9b81119824450ff49af4ebcee5ee9938b4fa9522"
CROS_WORKON_PROJECT="chromiumos/platform/modem-utilities"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-workon

DESCRIPTION="Chromium OS modem utilities"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	sys-apps/dbus
"

DEPEND="${RDEPEND}"
