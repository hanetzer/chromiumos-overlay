# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="20daaa4b0a1436a42fc5832c0d2e7509513d51f1"
CROS_WORKON_TREE="5a3a4f2282577c10a34a2dcd7b6a41f0351d4446"
CROS_WORKON_PROJECT="chromiumos/platform/touchbot"
CROS_WORKON_LOCALNAME="touchbot"

inherit cros-workon distutils

DESCRIPTION="Suite of control scripts for the Touchbot"
HOMEPAGE="http://www.chromium.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
