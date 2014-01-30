# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="9bc1faa85e42fa9a3694a9f8586133f983d82978"
CROS_WORKON_TREE="d2a318d236407bd0953a8a1e2b9ccffe51b48a68"
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
