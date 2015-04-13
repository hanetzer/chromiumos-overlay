# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="b4b19e6020e9524dea5f6337417ed6fbc3e3de42"
CROS_WORKON_TREE="409ee3bff5b853e4dc4aa5b383f25f64cf1a3d4b"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_DESTDIR="${S}"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-workon

DESCRIPTION="Chromium OS modem utilities"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="BSD-Google"
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
