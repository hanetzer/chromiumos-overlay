# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="7cd8a53df91659c395a6da0acb61b9240f6237a7"
CROS_WORKON_TREE="440d63878829a248b0f3fdd2fa266aa5e7b3be7e"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_DESTDIR="${S}/platform2"
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

src_unpack() {
	cros-workon_src_unpack
	S+="/modem-utilities"
}
