# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="f17cff75eb3e3285d858666019f0ea5de978312b"
CROS_WORKON_TREE="9839a8075c37114bc5d5124721a0466fba0de503"
CROS_WORKON_PROJECT="chromiumos/platform/crostestutils"

inherit cros-workon

DESCRIPTION="Test tool that recovers bricked Chromium OS test devices"
HOMEPAGE="http://www.chromium.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

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
