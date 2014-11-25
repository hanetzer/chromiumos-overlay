# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT="499b0eb4f23db2d7060c5e69b60565bd39baeb8e"
CROS_WORKON_TREE="731269e5c24c19c16b9aa0b33f763b32aa744908"
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
