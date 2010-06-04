# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit toolchain-funcs

DESCRIPTION="ChromeOS utilities"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE=""

# This target list should be architecture specific
# (no ACPI stuff on ARM fot instance)
TARGETS='gpio_setup'

src_unpack() {
    local src_dir="${CHROMEOS_ROOT}/src/platform/utils"
    elog "Source directory: ${src_dir}"
    mkdir -p "${S}"
    cp -a ${src_dir}/* "${S}" || die
}

src_compile() {
    tc-export CXX PKG_CONFIG
    emake ${TARGETS} || die "end compile failed."
}

src_install() {
    dosbin "${TARGETS}" || die "failed installing ($?)"
}
