# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="a6ca9be74b26dbf19c9b720b8e1d631176b77b48"
CROS_WORKON_PROJECT="chromiumos/platform/vpd"

inherit cros-workon

DESCRIPTION="ChromeOS vital product data utilities"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

# util-linux is for libuuid.
DEPEND="sys-apps/util-linux"
# shflags for dump_vpd_log.
RDEPEND="sys-apps/flashrom
	dev-libs/shflags
	dev-util/shflags"

src_compile() {
	tc-export CC
	emake all
}

src_install() {
	# This target list should be architecture specific
	# (no ACPI stuff on ARM for instance)
	dosbin vpd util/dump_vpd_log
}

# disabled due to buildbot failure
#src_test() {
#	emake test || die "test failed."
#}
