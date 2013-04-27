# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="d6289fbfc0a917adf9b62c8bbf404e66b2cd08ef"
CROS_WORKON_TREE="611a90f78e73564629217150d9c8e099034ed2ba"
CROS_WORKON_PROJECT="chromiumos/platform/modem-utilities"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-workon

DESCRIPTION="Chromium OS modem utilities"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"

RDEPEND="
	sys-apps/dbus
"

DEPEND="${RDEPEND}"
