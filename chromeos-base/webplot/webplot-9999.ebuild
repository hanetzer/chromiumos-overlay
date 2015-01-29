# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_PROJECT="chromiumos/platform/webplot"

PYTHON_COMPAT=( python2_7 )
inherit cros-workon distutils-r1

DESCRIPTION="Web drawing tool for touch devices"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/webplot/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="~*"
