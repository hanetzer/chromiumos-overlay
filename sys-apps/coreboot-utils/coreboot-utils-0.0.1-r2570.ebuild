# Copyright 2012 The Chromium OS Authors
# Distributed under the terms of the GNU General Public License v2
# $Header:

EAPI="4"
CROS_WORKON_COMMIT=("ee4365c787ec523b7ee1028ea100dcfbb331b3a9" "a929c2755eee3dec286585c58f3ac93690c7d270")
CROS_WORKON_TREE=("d26602ec1962e213f8bcff476c1f6ea1fb86d6e9" "be2e07b31f129f21329eca474cdd0830b3b24e30")
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
