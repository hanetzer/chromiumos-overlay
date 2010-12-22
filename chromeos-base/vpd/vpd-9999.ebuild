# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit cros-workon

DESCRIPTION="ChromeOS vital product data utilities"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

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
