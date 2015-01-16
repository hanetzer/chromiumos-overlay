# Copyright 2012 The Chromium OS Authors
# Distributed under the terms of the GNU General Public License v2
# $Header:

EAPI="4"
CROS_WORKON_COMMIT="519f1a7f0cc67eb0b4875d00197e7c64360e3b69"
CROS_WORKON_TREE="ae08267a64dbf24495b1c6110f48f5173c7400a1"
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

src_configure() {
	cros-workon_src_configure
}

is_x86() {
	use x86 || use amd64
}

src_compile() {
	tc-export CC
	# These two utilities are used on the host
	tc-env_build emake -C util/cbfstool
	if is_x86; then
		tc-env_build emake -C util/ifdtool
	fi

	# And these are used in the image
	if is_x86; then
		emake -C util/superiotool CC="${CC}"
		emake -C util/inteltool CC="${CC}"
		emake -C util/nvramtool CC="${CC}"
	fi
}

src_install() {
	dobin util/cbfstool/cbfstool
	if is_x86; then
		dobin util/ifdtool/ifdtool
		dobin util/superiotool/superiotool
		dobin util/inteltool/inteltool
		dobin util/nvramtool/nvramtool
	fi
}

pkg_preinst() {
	# TODO(reinauer) This is an ugly workaround to have the utilities
	# live outside the /build directory.
	# The package will never be installed to the image.
	mv $D/usr/bin/cbfstool /usr/bin
	if is_x86; then
		mv $D/usr/bin/ifdtool /usr/bin
	fi
}
