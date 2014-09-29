# Copyright 2012 The Chromium OS Authors
# Distributed under the terms of the GNU General Public License v2
# $Header:

EAPI="4"
CROS_WORKON_COMMIT="b5b34a3abd388359b7d1cba5a858e4e5a402b476"
CROS_WORKON_TREE="29c99ef57fca6b31fbaff6eefbc971e64c3f21e2"
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
