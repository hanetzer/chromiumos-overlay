# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"
CROS_WORKON_COMMIT="98501aec999d923fadbd03d06c5bf06713553d14"
CROS_WORKON_TREE="3eae974e2fb3b3cd39196db6bf2458b92d489a9f"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="cros_component"

inherit cros-workon platform

DESCRIPTION="Configurations for Chrome OS universial installer"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

src_compile() {
	true
}

src_install() {
	insinto /etc
	doins cros_component.config
}
