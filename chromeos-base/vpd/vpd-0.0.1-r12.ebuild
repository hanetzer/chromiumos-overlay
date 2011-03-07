# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="582ad9e9d060f04c726457191cb9f76688c05b40"

inherit cros-workon

DESCRIPTION="ChromeOS vital product data utilities"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE=""
DEPEND="sys-apps/util-linux"  # util-linux is for libuuid.
RDEPEND="x86? ( sys-apps/flashrom )"
         # TODO(yjlou): Currently, the flashrom is not verified on ARM platform.
         #              Hence, vpd only rdepends it on x86. vpd still works
         #              on ARM if flashrom is not installed.
         #              Will remove "x86? (...)" once flashrom is verified.

# This target list should be architecture specific
# (no ACPI stuff on ARM for instance)
TARGETS='vpd'

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
