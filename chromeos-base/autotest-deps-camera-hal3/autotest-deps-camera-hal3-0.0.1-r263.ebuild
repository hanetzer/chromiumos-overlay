# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="9cca67a5c9d069d37c9c8d83958445fedf1f3587"
CROS_WORKON_TREE="7e977fc18e9e39219f3cfe0bb3c6515b75678d15"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"
CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files

inherit cros-workon autotest-deponly

DESCRIPTION="Dependencies for camera_HAL3 autotest"
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

# Autotest enabled by default.
IUSE="+autotest"

AUTOTEST_DEPS_LIST="camera_hal3"

RDEPEND="
	media-libs/arc-camera3-test
"

DEPEND="${RDEPEND}"
