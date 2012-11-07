# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT=7fa1897bfcbb75601ff09b1be92236e554d279d6
CROS_WORKON_TREE="93e33c11b3db38f5deadbda394dec86f719f3e33"
CROS_WORKON_PROJECT="chromiumos/platform/touchbot"
CROS_WORKON_LOCALNAME="touchbot"

inherit cros-workon distutils

DESCRIPTION="Suite of control scripts for the Touchbot"
HOMEPAGE="http://www.chromium.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"
