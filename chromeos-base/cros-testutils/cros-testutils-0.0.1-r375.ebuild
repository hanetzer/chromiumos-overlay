# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="ed8493901eaa9a893b2e939f85b173628f238e25"
CROS_WORKON_TREE="3f7f91985f57538f19298cd265571c1cddbfc4e8"
CROS_WORKON_PROJECT="chromiumos/platform/crostestutils"
CROS_WORKON_LOCALNAME="crostestutils"

inherit cros-workon

DESCRIPTION="Host test utilities for ChromiumOS"
HOMEPAGE="http://www.chromium.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

RDEPEND="app-emulation/qemu
	app-portage/gentoolkit
	app-shells/bash
	chromeos-base/cros-devutils
	dev-util/crosutils
	dev-python/django
	"

# These are all either bash / python scripts.  No actual builds DEPS.
DEPEND=""

# Use default src_compile and src_install which use Makefile.
