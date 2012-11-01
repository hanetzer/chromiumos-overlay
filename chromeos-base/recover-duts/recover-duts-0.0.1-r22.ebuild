# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="cb9e5e1c009401211e440975d0c8eb3b3f65fbf9"
CROS_WORKON_TREE="d2db748e70e9aad4303421b87c37a4bd8a08406a"

EAPI="4"
CROS_WORKON_PROJECT="chromiumos/platform/crostestutils"

inherit cros-workon

DESCRIPTION="Test tool that recovers bricked Chromium OS test devices"
HOMEPAGE="http://www.chromium.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"

CROS_WORKON_LOCALNAME="crostestutils"


RDEPEND="
chromeos-base/chromeos-init
dev-lang/python
"

# These are all either bash / python scripts.  No actual builds DEPS.
DEPEND=""

# Use default src_compile and src_install which use Makefile.

src_install() {
	pushd "${S}/recover_duts" || die
	exeinto "/usr/bin"
	doexe recover_duts.py

	pushd "hooks" || die
	dodir /usr/bin/hooks
	exeinto /usr/bin/hooks
	doexe *
	popd
}
