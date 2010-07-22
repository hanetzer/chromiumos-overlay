# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# This is no longer used.  It's just here to uninstall the files
# installed before http://crosbug.com/3437 was fixed.

EAPI=2
CROS_WORKON_COMMIT="872bf84313e83f60c50160ea7fd37bf25da4848b"
inherit cros-workon toolchain-funcs

DESCRIPTION="Breakpad symbol dumper"
HOMEPAGE="http://code.google.com/p/google-breakpad/"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND=""
RDEPEND=""
