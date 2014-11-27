# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT="e9e1317b2f6656007f2d24ef1270e35508646472"
CROS_WORKON_TREE="50546687f61673c37161924ccb4da4aad69963d1"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_USE_VCSID=1

CROS_WORKON_LOCALNAME="platform2"  # With all platform2 subdirs
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_DESTDIR="${S}/platform2"

inherit cros-workon

DESCRIPTION="Platform2 for Chromium OS: a GYP-based incremental build system"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
