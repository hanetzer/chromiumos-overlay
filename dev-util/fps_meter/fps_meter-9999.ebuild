# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

CROS_WORKON_PROJECT="chromiumos/platform/experimental"
CROS_WORKON_LOCALNAME="../platform/experimental"
inherit cros-workon

DESCRIPTION="Fps meter for Chrome OS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/experimental/+/master/fps_meter/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="~*"

src_install() {
	newbin fps_meter/fps_meter.py fps_meter
}
