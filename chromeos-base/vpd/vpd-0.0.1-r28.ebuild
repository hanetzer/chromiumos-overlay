# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="986080c87666ec6897e4f48a88ead96335c58efd"
CROS_WORKON_PROJECT="chromiumos/platform/vpd"

inherit cros-workon

DESCRIPTION="ChromeOS vital product data utilities"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""
DEPEND="sys-apps/util-linux"  # util-linux is for libuuid.
RDEPEND="sys-apps/flashrom dev-libs/shflags dev-util/shflags"  # shflags for dump_vpd_log

# This target list should be architecture specific
# (no ACPI stuff on ARM for instance)
TARGETS='vpd util/dump_vpd_log'

src_compile() {
    tc-export CXX PKG_CONFIG
    emake CC="$(tc-getCC)" all || die "compilation failed."
}

src_install() {
    dosbin ${TARGETS} || die "installation failed ($?)"
}

# disabled due to buildbot failure
#src_test() {
#    emake test || die "test failed."
#}
