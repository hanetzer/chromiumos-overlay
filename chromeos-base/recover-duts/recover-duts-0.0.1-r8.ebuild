# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="b2be2f15de14e8eb878e5f1e24ee1835d0758321"
CROS_WORKON_TREE="626eb6642cb35ad02181381b19e49f0420392790"

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
