# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="c5a20ae6e46de4670ff1c881749917a62000fcf2"
CROS_WORKON_TREE="3f425284de2289b90b3c3c73b3c16d558f397083"
CROS_WORKON_PROJECT="chromiumos/platform/crostestutils"
CROS_WORKON_LOCALNAME="crostestutils"

inherit cros-workon

DESCRIPTION="Test tool that recovers bricked Chromium OS test devices"
HOMEPAGE="http://www.chromium.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

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
