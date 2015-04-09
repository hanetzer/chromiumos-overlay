# Copyright 2012 The Chromium OS Authors
# Distributed under the terms of the GNU General Public License v2
# $Header:

EAPI="4"
CROS_WORKON_COMMIT="e317ddca14bc36bc36e6406b758378c88e9ae04e"
CROS_WORKON_TREE="af08d363062138f5f9e2bc58b74b3141b8ba67b4"
CROS_WORKON_PROJECT="chromiumos/third_party/coreboot"
CROS_WORKON_LOCALNAME="coreboot"

inherit cros-workon toolchain-funcs

RDEPEND="sys-apps/pciutils"
DEPEND="${RDEPEND}"

DESCRIPTION="Utilities for modifying coreboot firmware images"
HOMEPAGE="http://coreboot.org"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="cros_host"

src_configure() {
	cros-workon_src_configure
}

is_x86() {
	use x86 || use amd64
}

src_compile() {
	tc-export CC
	if use cros_host; then
		emake -C util/cbfstool obj="${PWD}/util/cbfstool"
	else
		emake -C util/cbmem CC="${CC}"
	fi
	if is_x86; then
		if use cros_host; then
			emake -C util/ifdtool
		else
			emake -C util/superiotool CC="${CC}"
			emake -C util/inteltool CC="${CC}"
			emake -C util/nvramtool CC="${CC}"
		fi
	fi
}

src_install() {
	if use cros_host; then
		dobin util/cbfstool/cbfstool
	else
		dobin util/cbmem/cbmem
	fi
	if is_x86; then
		if use cros_host; then
			dobin util/ifdtool/ifdtool
		else
			dobin util/superiotool/superiotool
			dobin util/inteltool/inteltool
			dobin util/nvramtool/nvramtool
		fi
	fi
}
