# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT=12cae25ac55aebbc6a86536f49607eea677fffbc
CROS_WORKON_TREE="6ab461747188bc5842cccf9d322d6d4be2ccc159"

EAPI="4"
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
	dev-util/shflags"

src_compile() {
	tc-export CC
	emake all
}

src_install() {
	# This target list should be architecture specific
	# (no ACPI stuff on ARM for instance)
	dosbin vpd vpd_s util/dump_vpd_log
}

# disabled due to buildbot failure
#src_test() {
#	emake test || die "test failed."
#}
