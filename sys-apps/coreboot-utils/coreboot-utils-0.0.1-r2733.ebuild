# Copyright 2012 The Chromium OS Authors
# Distributed under the terms of the GNU General Public License v2
# $Header:

EAPI="4"
CROS_WORKON_COMMIT=("16b684416e0af016f150a76a63cbf8b903f5361c" "e5500a319bd34abfd8b13851a4e758fad154f5d4")
CROS_WORKON_TREE=("494782fb583cdb4fa8a0d37bcbaa4e9f8132e1c9" "646020c5bc6d87ff0793d0ce03f0ad13872305ad")
CROS_WORKON_PROJECT=(
	"chromiumos/third_party/coreboot"
	"chromiumos/platform/vboot_reference"
)
CROS_WORKON_LOCALNAME=(
	"coreboot"
	"../platform/vboot_reference"
)
CROS_WORKON_DESTDIR=(
	"${S}"
	"${S}/3rdparty/vboot"
)

inherit cros-workon toolchain-funcs

RDEPEND="sys-apps/pciutils"
DEPEND="${RDEPEND}"

DESCRIPTION="Utilities for modifying coreboot firmware images"
HOMEPAGE="http://coreboot.org"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="cros_host mma"

src_configure() {
	cros-workon_src_configure
}

is_x86() {
	use x86 || use amd64
}

src_compile() {
	tc-export CC
	emake -C util/cbfstool obj="${PWD}/util/cbfstool"
	if use cros_host; then
		emake -C util/archive CC="${CC}"
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
		if use mma; then
			emake -C util/cbmem CC="${CC}"
		fi
	fi
}

src_install() {
	dobin util/cbfstool/cbfstool
	if use cros_host; then
		dobin util/archive/archive
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
		if use mma; then
			dobin util/mma/mma_setup_test.sh
			dobin util/mma/mma_get_result.sh
			dobin util/mma/mma_automated_test.sh
			insinto /etc/init
			doins util/mma/mma.conf
		fi
	fi
}
