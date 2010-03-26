# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

DESCRIPTION="Python script to read/write u-boot environment"
SLOT="0"
KEYWORDS="arm x86"
IUSE=""

DEPEND=">=dev-lang/python-2.5"
RDEPEND="${DEPEND}"

src_install() {
	dobin ${CHROMEOS_ROOT}/src/platform/uboot-env/uboot-env.py || die
}
