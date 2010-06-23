# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# This just copies a pre-compiled dump_syms binary from the crash dumper
# repo to /usr/bin so the host can use it when building packages.  See
# http://crosbug.com/3437.

EAPI=2

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

src_install() {
	dobin dump_syms.i386
	dobin sym_upload.i386
}
